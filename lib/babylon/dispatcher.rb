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
    
    def dispatch(stanza)
      if @routes[stanza.name.intern]
        # Pass the stanza to the controller who actually said he could handle the stanza
        @routes[stanza.name.intern].handle(stanza)
      else
        puts "Nobody can handle #{stanza}"
      end
    end
    
    def send(stanza)
      stanza.attributes["from"] = @config["jid"] if (stanza.is_a?(REXML::Element) && !stanza.attributes["from"])
      @xmpp_handler.send_data(stanza)
    end
    
    def stop_streaming
      send(@stop_stream)
    end
    
    def start_streaming(xmpp_handler)
      # Called once the connection has been established!
      @xmpp_handler = xmpp_handler
      # And now, that we're connected, we must send a <stream>
      stream = REXML::Element.new("stream:stream")
      stream.add_namespace(stream_namespace)
      stream.add_attribute('xmlns:stream', 'http://etherx.jabber.org/streams')
      stream.add_attribute('to', stream_to)
      stream.add_text("--")
      @start_stream, @stop_stream = stream.to_s.split("--")
      send(@start_stream)
    end
  
  end

end
