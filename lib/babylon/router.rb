module Babylon
  module Router
    # Insert a route sorted
    
    # Routes should be of form {name => params}
    # Route : params = {"action"=>"...", "namespaces"=>{"alias" => "url", "alias" => "url"}, "priority"=>0, "controller"=>"...", "xpath"=>"..."}}
    
    def add_routes(routes)
      routes.each do |name, params|
        add_route(Route.new(name, params))
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

    # Route : params = {"action"=>"...", "namespaces"=>{"alias" => "url", "alias" => "url"}, "priority"=>0, "controller"=>"...", "xpath"=>"..."}}
    
    def initialize(name, params)
      @priority   = params["priority"]
      @xpath      = params["xpath"]
      @namespaces = params["namespaces"]
      @controller = Kernel.const_get("#{params["controller"].capitalize}Controller")
      @action     = params["action"]
    end

    # Checks that the route matches the stanzas and calls the the action on the controller
    def accepts?(connection, stanza)
      stanza.xpath(@xpath, stanza.namespaces).first ? self : false
    end
    
  end
  
end
