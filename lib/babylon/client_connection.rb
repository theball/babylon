require 'xmpp4r/jid'
require 'ramaze/gestalt'
require 'sasl'

require 'dnsruby'

module Babylon
  class ClientConnection < XmppConnection
    KEEPALIVE_INTERVAL = 10

    def self.connect(config)
      p :config => config
      unless config['host'] && config['port']
        Dnsruby::Resolver.use_eventmachine true
        Dnsruby::Resolver.start_eventmachine_loop false
        domain = Jabber::JID.new(config['jid']).domain
        res = Dnsruby::Resolver.new
        df = res.send_async(Dnsruby::Message.new("_xmpp-client._tcp." + domain,
                                                 Dnsruby::Types.SRV))
        df.callback {|msg|
          rrs = []
          msg.each_resource { |rr|
            rrs << rr if rr.kind_of? Dnsruby::RR::IN::SRV
          }
          rrs.sort { |rr1,rr2| rr1.priority <=> rr2.priority }
          if rrs[0]
            # TODO: fallback/balancing, asynchronous resolving of A/AAAA
            config['host'] = rrs[0].target.to_s
            config['port'] = rrs[0].port
          else
            config['host'] = domain
            config['port'] ||= 5222
          end
          p :config => config
          super(config)
        }
        df.errback {|msg, err|
          raise "can't resolve #{name}: #{err}"
        }
      else
        p :config => config
        super(config)
      end
    end

    def initialize(*a)
      super
      @state = :wait_for_stream
      @is_tls = false
      @is_authenticated = false
      @sasl = nil
      @last_send = Time.now
      reset_keepalive_timer
    end
    def is_tls?
      @is_tls
    end

    class XMPPPreferences < SASL::Preferences
      def initialize(connection)
        @connection = connection
      end
      def realm
        @connection.jid.domain
      end
      def digest_uri
        "xmpp/#{@connection.jid.domain}"
      end
      def username
        @connection.jid.node
      end
      def allow_plaintext?
        @connection.is_tls?
      end
    end
    class PasswordPreferences < XMPPPreferences
      def initialize(password, connection)
        @password = password
        super(connection)
      end
      def has_password?
        true
      end
      def password
        @password
      end
    end
    class AnonymousPreferences < XMPPPreferences
      def want_anonymous?
        true
      end
    end

    def send_xmpp(xml)
      super
      @last_send = Time.now
    end

    def receive_stanza(stanza)
      p :receive_stanza => [stanza.name, stanza.namespaces, stanza.attributes]
      case @state

      when :wait_for_stream
        if stanza.name == 'stream:stream'
          if stanza['version'] == '1.0'
            @state = :wait_for_features
          else
            raise 'Please implement non-SASL authentication or upgrade your server'
          end
        else
          raise
        end

      when :wait_for_features
        if stanza.name == 'stream:features'
          @stream_features = stanza
          check_features
        else
          raise "Unexpected: #{stanza.name}"
        end

      when :wait_for_tls
        if stanza.name == 'proceed'
          start_tls(:cert_chain_file => @config['ssl cert'])
          Logger.info " -- TLS"
          @is_tls = true
          restart_stream
          @state = :wait_for_stream
        else
          raise 'TLS handshake error'
        end
        
      when :wait_for_auth
        msg_name, msg_content = stanza.name, (stanza.text ?
                                              Base64::decode64(stanza.text) :
                                              nil)
        msg_name, msg_content = @sasl.receive(msg_name, msg_content)
        if msg_name
          send_sasl_message(msg_name, msg_content)
        end
        if @sasl.success?
          @sasl = nil # Get GC'ed
          Logger.info " -- Authenticated"
          @is_authenticated = true
          restart_stream
          @state = :wait_for_stream
        elsif @sasl.failure?
          raise 'Authentication failure'
        end

      when :wait_for_bind
        if stanza.name == 'iq' && stanza['id'] == 'bind'
          if stanza['type'] == 'result'
            @is_bound = true
            check_features
          else
            raise 'Resource binding error'
          end
        end

      when :wait_for_session
        if stanza.name == 'iq' && stanza['id'] == 'session'
          if stanza['type'] == 'result'
            @is_session = true
            check_features
          else
            raise 'Session binding error'
          end
        end

      when :connected
        super

      end
    end

    def check_features
p [@stream_features.to_xml, (@stream_features.xpath '.').to_xml]
      features = (@stream_features.xpath '*').map { |e| e.name }
      
      if (not @is_tls) && features.include?('starttls')
        send_xml Ramaze::Gestalt.build {
          starttls :xmlns => 'urn:ietf:params:xml:ns:xmpp-tls'
        }
        @state = :wait_for_tls

      elsif (not @is_authenticated) && features.include?('mechanisms')
        mechanisms = []
        if (mechanisms_element = @stream_features.elements['mechanisms'])
          mechanisms_element.each_element('mechanism') do |mechanism_element|
            mechanisms << mechanism_element.text
          end
        end
        
        pref = if @config['anonymous']
                 AnonymousPreferences.new(self)
               else
                 PasswordPreferences.new(@config['password'], self)
               end
        @sasl = SASL.new(mechanisms, pref)
        msg_name, msg_content = @sasl.start
        send_sasl_message(msg_name, msg_content, @sasl.mechanism)
        @state = :wait_for_auth

      elsif (not @is_bound) && features.include?('bind')
=begin
        iq = Jabber::Iq.new(:set)
        iq.id = 'bind'
        iq.add(bind = REXML::Element.new('bind'))
        bind.add_namespace 'urn:ietf:params:xml:ns:xmpp-bind'
        if jid.resource
          bind.add(REXML::Element.new('resource')).text = jid.resource
        end
=end
        send_xml Ramaze::Gestalt.build {
          iq(:type => 'set', :id => 'bind') {
            bind(:xmlns => 'urn:ietf:params:xml:ns:xmpp-bind') {
              jid.resource ? resource { jid.resource } : nil
            }
          }
        }
        @state = :wait_for_bind

      elsif (not @is_session) && features.include?('session')
=begin
        iq = Jabber::Iq.new(:set)
        iq.id = 'session'
        iq.add(session = REXML::Element.new('session'))
        session.add_namespace 'urn:ietf:params:xml:ns:xmpp-session'
=end
        send_xml Ramaze::Gestalt.build {
          iq(:type => 'set', :id => 'session') {
              session(:xmlns => 'urn:ietf:params:xml:ns:xmpp-session')
          }
        }
        @state = :wait_for_session

      else
        Logger.info " -- Connected"
        @state = :connected
      end

    end
    
    def send_sasl_message(name, content=nil, mechanism=nil)
=begin
      stanza = REXML::Element.new(name)
      stanza.add_namespace(NS_SASL)
      stanza.attributes['mechanism'] = mechanism
      stanza.text = content ? Base64::encode64(content).gsub(/\s/, '') : nil
=end

      send_xml Ramaze::Gestalt.build {
        send(name, :xmlns => NS_SASL, :mechanism => mechanism) {
          content ? Base64::encode64(content).gsub(/\s/, '') : nil
        }
      }
    end

    NS_SASL = 'urn:ietf:params:xml:ns:xmpp-sasl'

    def keepalive_timer
      if @state == :connected && @last_send + KEEPALIVE_INTERVAL <= Time.now
        send_xml ' '
        @last_send = Time.now
      end
      reset_keepalive_timer
    end

    def reset_keepalive_timer
      @keepalive_timer.cancel if defined?(@keepalive_timer) && @keepalive_timer
      @keepalive_timer = EventMachine::Timer.new(@last_send + KEEPALIVE_INTERVAL - Time.now, &method(:keepalive_timer))
    end

    def stream_namespace
      'jabber:client'
    end

    def stream_to
      jid.domain
    end

    def jid
      @jid ||= Jabber::JID.new(@config['jid'])
    end
  end
end
