module Babylon
  module Router

    # Creates a simple DSL for stanza routing.
    class DSL
      attr_reader :routes

      def initialize
        @routes = []
      end

      # Match an xpath.
      def xpath(path)
        @routes << {"xpath" => path}
        self
      end

      # Set the priority of the last created route.
      def priority(n)
        set(:priority, n)
        self
      end

      # Match a disco_info query.
      def disco_info(node = nil)
        disco_for(:info, node)
      end

      # Match a disco_items query.
      def disco_items(node = nil)
        disco_for(:items, node)
      end

      # Map a route to a specific controller and action.
      def to(params)
        set(:controller, params[:controller])
        set(:action, params[:action])
        # We now have all the properties we really need to create a route.
        route = Route.new(@routes.pop)
        @routes << route
        self
      end

      protected
      # We do this magic, or crap depending on your perspective, because we don't know whether we're setting values on a 
      # Hash or a Route. We can't create the Route until we have a controller and action.
      def set(property, value)
        last = @routes.last
        last[property.to_s] = value if last.is_a?(Hash)
        last.send("#{property.to_s}=", value) if last.is_a?(Route)
      end

      def disco_for(type, node = nil)
        str = "//iq[@type='get']/*[namespace(., 'query', 'http://jabber.org/protocol/disco##{type.to_s}')"
        str += " and @node = '#{node}'" if node
        str += "]"
        xpath(str)
      end
    end
  end
end
