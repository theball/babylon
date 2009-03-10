module Babylon
  ##
  # ComponentConnection is in charge of the XMPP connection itself.
  # Upon stanza reception, and depending on the status (connected... etc), this component will handle or forward the stanzas.
  class ComponentConnection < XmppConnection
    require 'digest/sha1'
    
    ##
    # Creates a new ComponentConnection and waits for data in the stream
    def initialize(*a)
      super
      @state = :wait_for_stream
    end
    
    ##
    # Connection_completed is called when the connection (socket) has been established and is in charge of "building" the XML stream 
    # to establish the XMPP connection itself.
    # We use a "tweak" here to send only the starting tag of stream:stream
    def connection_completed
      super
      builder = Nokogiri::XML::Builder.new do
        self.send('stream:stream', {'xmlns' => "jabber:component:accept", 'xmlns:stream' => 'http://etherx.jabber.org/streams', 'to' => @context.jid}) do
          paste_content_here #  The stream:stream element should be cut here ;)
        end
      end
      @start_stream, @stop_stream = builder.to_xml.split('<paste_content_here/>')
      send(@start_stream)
    end

    ##
    # XMPP Component handshake as defined in XEP-0114:
    # http://xmpp.org/extensions/xep-0114.html
    def receive_stanza(stanza)
      case @state
      when :connected # Most frequent case
          super # Can be dispatched
          
      when :wait_for_stream
        if stanza.name == "stream:stream" && stanza.attributes['id']
          # This means the XMPP session started!
          # We must send the handshake now.
          hash = Digest::SHA1::hexdigest(stanza.attributes['id'].content + @password)
          handshake = Nokogiri::XML::Node.new("handshake", stanza.document)
          handshake.content = hash
          send(handshake)
          @state = :wait_for_handshake
        else
          raise
        end

      when :wait_for_handshake
        if stanza.name == "handshake"
          @connection_callback.call(self) if @connection_callback
          @state = :connected
        elsif stanza.name == "stream:error"
          raise AuthenticationError
        else
          raise
        end

      end
    end
    
    ##
    # Namespace of the component
    def stream_namespace
      'jabber:component:accept'
    end
    
  end
end
