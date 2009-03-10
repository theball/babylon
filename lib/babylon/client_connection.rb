module Babylon
  
  ##
  # ClientConnection is in charge of the XMPP connection for a Regular XMPP Client.
  # So far, SASL Plain authenticationonly is supported
  # Upon stanza reception, and depending on the status (connected... etc), this component will handle or forward the stanzas.
  class ClientConnection < XmppConnection
    require 'digest/sha1'
    require 'base64'
    require 'resolv'
    

    attr_reader :binding_iq_id, :session_iq_id

    ##
    # Creates a new ClientConnection and waits for data in the stream
    def initialize(params)
      super(params)
      @state = :wait_for_stream
    end
    
    ##
    # Connects the ClientConnection based on SRV records for the jid's domain, if no host or port has been specified.
    # In any case, we give priority to the specified host and port.
    def self.connect(params, &block)
      return super(params, &block) if params["host"] && params["port"]
      
      begin
        begin
          srv = []
          Resolv::DNS.open { |dns|
            # If ruby version is too old and SRV is unknown, this will raise a NameError
            # which is caught below
            host_from_jid = params["jid"].split("/").first.split("@").last
            Babylon.logger.debug("RESOLVING: _xmpp-client._tcp.#{host_from_jid} (SRV)")
            srv = dns.getresources("_xmpp-client._tcp.#{host_from_jid}", Resolv::DNS::Resource::IN::SRV)
          }
          # Sort SRV records: lowest priority first, highest weight first
          srv.sort! { |a,b| (a.priority != b.priority) ? (a.priority <=> b.priority) : (b.weight <=> a.weight) }
          # And now, for each record, let's try to connect.
          srv.each { |record|
            begin
              params["host"] = record.target.to_s
              params["port"] = Integer(record.port)
              super(params, &block)
              # Success
              break
            rescue SocketError, Errno::ECONNREFUSED
              # Try next SRV record
            end
          }
        rescue NameError
          Babylon.logger.debug "Resolv::DNS does not support SRV records. Please upgrade to ruby-1.8.3 or later! \n #{$!} : #{$!.inspect}"
        end
      end
    end


    ##
    # Connection_completed is called when the connection (socket) has been established and is in charge of "building" the XML stream 
    # to establish the XMPP connection itself.
    # We use a "tweak" here to send only the starting tag of stream:stream
    def connection_completed
      super
      builder = Nokogiri::XML::Builder.new do
        self.send('stream:stream', {'xmlns' => @context.stream_namespace(), 'xmlns:stream' => 'http://etherx.jabber.org/streams', 'to' => @context.jid.split("/").first.split("@").last,  'version' => '1.0'}) do
          paste_content_here #  The stream:stream element should be cut here ;)
        end
      end
      @outstream = builder.doc
      start_stream, stop_stream = builder.to_xml.split('<paste_content_here/>')
      send(start_stream)
    end

    ##
    # Called upon stanza reception
    # Marked as connected when the client has been SASLed, authenticated, biund to a resource and when the session has been created
    def receive_stanza(stanza)
      case @state
      when :connected
        super # Can be dispatched
      
      when :wait_for_stream
        if stanza.name == "stream:stream" && stanza.attributes['id']
          @state = :wait_for_auth_mechanisms unless @success
          @state = :wait_for_bind if @success
        end
        
      when :wait_for_auth_mechanisms
        if stanza.name == "stream:features"
          if stanza.at("starttls") # we shall start tls
            starttls = Nokogiri::XML::Node.new("starttls", @outstream)
            starttls["xmlns"] = stanza.at("starttls").namespaces.first.last
            send(starttls)
            @state = :wait_for_proceed
          elsif stanza.at("mechanisms") # tls is ok
            if stanza.at("mechanisms/[contains(mechanism,'PLAIN')]")
              # auth_text = "#{jid.strip}\x00#{jid.node}\x00#{password}"
              auth = Nokogiri::XML::Node.new("auth", @outstream)
              auth['mechanism'] = "PLAIN"
              auth['xmlns'] = stanza.at("mechanisms").namespaces.first.last
              auth.content = Base64::encode64([jid, jid.split("@").first, @password].join("\000")).gsub(/\s/, '')
              send(auth)
              @state = :wait_for_success
            end
          end
        end
      
      when :wait_for_success
        if stanza.name == "success" # Yay! Success
          @success = true
          @state = :wait_for_stream
          send @outstream.root.to_xml.split('<paste_content_here/>').first
        elsif stanza.name == "failure"
          if stanza.at("bad-auth") || stanza.at("not-authorized")
            raise AuthenticationError
          else
          end
        else
          # Hum Failure...
        end
      
      when :wait_for_bind
        if stanza.name == "stream:features"
          if stanza.at("bind")
            # Let's build the binding_iq
            @binding_iq_id = Integer(rand(10000))
            builder = Nokogiri::XML::Builder.new do
              iq(:type => "set", :id => @context.binding_iq_id) do
                bind(:xmlns => "urn:ietf:params:xml:ns:xmpp-bind")  do                
                  if @context.jid.split("/").size == 2 
                    resource(@context.jid.split("/").last)
                  else
                    resource("babylon_client_#{@context.binding_iq_id}")
                  end
                end
              end
            end
            iq = @outstream.add_child(builder.doc.root)
            send(iq)
            @state = :wait_for_confirmed_binding
          end
        end
      
      when :wait_for_confirmed_binding
        if stanza.name == "iq" && stanza["type"] == "result" && Integer(stanza["id"]) ==  @binding_iq_id
          if stanza.at("jid") 
            jid= stanza.at("jid").text
          end
        end
        # And now, we must initiate the session
        @session_iq_id = Integer(rand(10000))
        builder = Nokogiri::XML::Builder.new do
          iq(:type => "set", :id => @context.session_iq_id) do
            session(:xmlns => "urn:ietf:params:xml:ns:xmpp-session")
          end
        end
        iq = @outstream.add_child(builder.doc.root)
        send(iq)
        @state = :wait_for_confirmed_session
        
      when :wait_for_confirmed_session
        if stanza.name == "iq" && stanza["type"] == "result" && Integer(stanza["id"]) ==  @session_iq_id && stanza.at("session")
          # And now, send a presence!
          presence = Nokogiri::XML::Node.new("presence", @outstream)
          send(presence)
          @connection_callback.call(self) if @connection_callback
          @state = :connected
        end
        
      when :wait_for_proceed
        start_tls() # starting TLS
        @state = :wait_for_stream
        send @outstream.root.to_xml.split('<paste_content_here/>').first
      end

    end

    ##
    # Namespace of the client
    def stream_namespace
      "jabber:client"
    end

  end
end
