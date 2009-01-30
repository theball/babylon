module Babylon
  module Base
    class Controller
      
      attr_accessor :sequences, :routes
      
      def attach(dispatcher)
        @dispatcher = dispatcher
      end
      
      def send(element)
        @dispatcher.send(element)
      end
      
      def route(sequence, controller)
        @routes = Hash.new unless @routes
        if sequence.size == 1
          @routes[sequence[0]] = controller
        else
          @routes[sequence[0]].route(sequence[1..sequence.size], controller)
        end
      end
      
      # This set handler for this element
      def responds_to(sequence)
        @sequences = Array.new unless @sequences
        @sequences << sequence
      end
      
      # Called by a parent controller
      def handle(element)
        # Let's look a the element's subelements and, if we have a route for them, take it!
        # We assume that a controller might have "duplicate" routes for the same element.
        fallback_route = true
        element.elements.each do |child|
          if @routes && @routes[child.name.intern]
            @routes[child.name.intern].handle(element)
            fallback_route = false
          end
        end
        # If not, let's call on_element(element)
        on_element(element) if fallback_route
      end
      
      # Called when the element is received
      # Shall be overwritten
      def on_element(element)
        # puts "#{element}"
      end
      
      # Called when the component is connected
      # Useful to setup timers or event that should only happen when the coomponent is connected!
      def on_connected()
      end
      
    end    
  end
end