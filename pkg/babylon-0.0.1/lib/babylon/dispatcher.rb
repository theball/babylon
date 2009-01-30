require 'digest/sha1'

module Babylon
  # This class is in charge of Dispatching the XML elements to the right controllers. 
  class Dispatcher
  
    attr_reader :routes

    def initialize(config = {}, controllers = [])
      @config = config
      @controllers = controllers
      @routes = Hash.new
      
      # A Trigger is a pair of both an Array and Controller
      triggers =  Array.new
      # And now let's build the routes!
      # Te routes that the the dispatcher knows are only routes of size 1!
      controllers.each do |controller|
        controller.attach(self)
        controller.sequences.each do |sequence|
          triggers << [sequence, controller]
        end
      end
      
      # We should now order the triggers by size of the sequence:
      triggers.sort! { |t, v| t[0].size <=> v[0].size}
      
      triggers.each do |sequence, controller|
        if sequence.size == 1
          @routes[sequence[0]] = controller
        else
          @routes[sequence[0]].route(sequence[1..sequence.size], controller)
        end
      end    
    end
    
    def dispatch(message)
      if message.name == "stream"
        if message.attributes['id']
          # This means the XMPP session started!
          # We must send the handshake now.
          hash = Digest::SHA1::hexdigest(message.attributes['id'] + @config['password'])
          handshake = REXML::Element.new("handshake")
          handshake.add_text(hash)
          send(handshake)
        else
          # Weird!
        end
      elsif message.name == "handshake"
        # Awesome, we're now connected and authentified, let's callback the controllers to tell them we're connected!
        @controllers.each do |controller|
          controller.on_connected
        end
      else
        if @routes[message.name.intern]
          # Pass the message to the controller who actually said he could handle the message
          @routes[message.name.intern].handle(message)
        else
          puts "Nobody can handle #{message}"
        end
      end
    end
    
    def send(message)
      message.attributes["from"] = @config["jid"] if (message.is_a?(REXML::Element) && !message.attributes["from"])
      @xmpp_handler.send_data(message)
    end
    
    def stop_streaming
      send(@stop_stream)
    end
    
    def start_streaming(xmpp_handler)
      # Called once the connection has been established!
      @xmpp_handler = xmpp_handler
      # And now, that we're connected, we must send a <stream>
      stream = REXML::Element.new("stream:stream")
      stream.add_namespace('jabber:component:accept') # This is a component!
      stream.add_attribute('xmlns:stream', 'http://etherx.jabber.org/streams')
      stream.add_attribute('to', @config["jid"])
      stream.add_text("--")
      @start_stream, @stop_stream = stream.to_s.split("--")
      send(@start_stream)
    end
  
  end

end
