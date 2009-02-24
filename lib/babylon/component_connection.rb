require 'digest/sha1'

module Babylon
  class ComponentConnection < XmppConnection
    def initialize(*a)
      super
      @state = :wait_for_stream
    end

    ##
    # XMPP Component handshake as defined in XEP-0114:
    # http://xmpp.org/extensions/xep-0114.html
    def receive_stanza(stanza)
      case @state

      when :wait_for_stream
        if stanza.name == "stream:stream" && stanza.attributes['id']
          # This means the XMPP session started!
          # We must send the handshake now.
          hash = Digest::SHA1::hexdigest(stanza.attributes['id'].content + @config['password'])
          handshake = Nokogiri::XML::Node.new("handshake", stanza.document)
          handshake.content = hash
          send(handshake)
          @state = :wait_for_handshake
        else
          raise
        end

      when :wait_for_handshake
        if stanza.name == "handshake"
          # Awesome, we're now connected and authentified, let's
          # callback the controllers to tell them we're connected!
          # TODO
          @state = :connected
        else
          raise
        end

      when :connected
        super # Can be dispatched

      end
    end
    
    def stream_namespace
      'jabber:component:accept'
    end

    def stream_to
      @config['jid']
    end
  end
end
