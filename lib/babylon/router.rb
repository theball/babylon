module Babylon
  module Router
    # Insert a route sorted
    
    # Routes should be of form [route1, route2, ...]
    # route = ["xpath", {"priority"=>0, "action"=>"echo", "controller"=>"message"}]
    def add_routes(routes)
      routes.each do |r|
        add_route(Route.new(r[1]["priority"], r[0], Kernel.const_get("#{r[1]["controller"].capitalize}Controller"), r[1]["action"].intern))
      end
    end
    
    def add_route(route)
      @routes ||= []
      @routes << route
      @routes.sort! { |r1,r2|
        r2.priority <=> r1.priority
      }
    end

    # Look for a route in the router and pass to a matching
    # route. Returns true if there was a match and the stanza has been
    # routed or false if not and the next router in a chain shall be
    # tried.
    def route(connection, stanza)
      @routes ||= []
      @routes.each { |route|
        if route.accepts?(connection, stanza)
          # Here should happen the magic : call the controller
          route.controller.new({:stanza => stanza}).perform(route.action) do |response|
            connection.send(response)
          end
          return true
        end
      }
      false
    end

    # Throw away all added routes from this router. Helpful for
    # testing.
    def purge_routes!
      @routes = []
    end
  end

  ##
  # Main router where all dispatchers shall register.
  module CentralRouter
    extend Router
  end

  class Route
    include Router

    # Higher numbers come first
    attr_reader :priority, :controller, :action

    def initialize(priority, match, kontroller, action)
      @priority   = priority
      @match      = match
      @controller = kontroller
      @action     = action
    end

    # Checks that the route matches the stanzas and calls the the action on the controller
    def accepts?(connection, stanza, *context)
      REXML::XPath.first(stanza, @match) ? self : false
    end
    
  end
  
end
