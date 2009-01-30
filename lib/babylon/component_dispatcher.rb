module Babylon
  class ComponentDispatcher < Dispatcher
    def dispatch(stanza)
      if stanza.name == "stream"
        if stanza.attributes['id']
          # This means the XMPP session started!
          # We must send the handshake now.
          hash = Digest::SHA1::hexdigest(stanza.attributes['id'] + @config['password'])
          handshake = REXML::Element.new("handshake")
          handshake.add_text(hash)
          send(handshake)
        else
          # Weird!
        end
      elsif stanza.name == "handshake"
        # Awesome, we're now connected and authentified, let's callback the controllers to tell them we're connected!
        @controllers.each do |controller|
          controller.on_connected
        end
      else
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
