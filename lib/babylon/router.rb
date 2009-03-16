require File.dirname(__FILE__)+"/router/dsl"

module Babylon
  
  ##
  # The router is in charge of sending the right stanzas to the right controllers based on user defined Routes.
  module Router
    
    @@connection = nil
    
    ##
    # Add several routes to the router
    # Routes should be of form {name => params}
    def add_routes(routes)
      routes.each do |name, params|
        add_route(Route.new(params))
      end
    end
    
    ##
    # Connected is called by the XmppConnection to indicate that the XMPP connection has been established
    def connected(connection)
      @@connection = connection
    end
    
    ## 
    # Accessor for @@connection
    def connection
      @@connection
    end
    
    ##
    # Insert a route and makes sure that the routes are sorted
    def add_route(route)
      @routes ||= []
      @routes << route
      sort
    end

    # Look for the first matching route and calls the corresponding action for the corresponding controller.
    # Sends the response on the XMPP stream/ 
    def route(stanza)
      return false if !@@connection
      @routes ||= []
      @routes.each { |route|
        if route.accepts?(stanza)
          # Here should happen the magic : call the controller
          Babylon.logger.info("ROUTING TO #{route.controller}::#{route.action}")
          controller = route.controller.new({:stanza => stanza})
          controller.perform(route.action) do |response|
            # Response should be a Nokogiri::Nodeset
            @@connection.send(response)
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

    # Run the router DSL.
    def draw(&block)
      r = Router::DSL.new
      r.instance_eval(&block)
      r.routes.each do |route|
        raise("Route lacks destination: #{route.inspect}") unless route.is_a?(Route)
      end
      @routes ||= []
      @routes += r.routes
      sort
    end

    private
    def sort
      @routes.sort! { |r1,r2|
        r2.priority <=> r1.priority
      }
    end
  end

  ##
  # Main router where all dispatchers shall register.
  module CentralRouter
    extend Router
  end

  ##
  # Route class which associate an XPATH match and a priority to a controller and an action
  class Route

    attr_accessor :priority, :controller, :action, :xpath
    
    ##
    # Creates a new route
    def initialize(params)
      raise("No controller given for route") unless params["controller"]
      raise("No action given for route") unless params["action"]
      @priority   = params["priority"] || 0
      @xpath      = params["xpath"]
      @controller = Kernel.const_get("#{params["controller"].capitalize}Controller")
      @action     = params["action"]
    end

    ##
    # Checks that the route matches the stanzas and calls the the action on the controller
    def accepts?(stanza)
      stanza.xpath(@xpath, XpathHelper.new).first ? self : false
    end
    
  end
  
end
