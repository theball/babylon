require 'digest/sha1'

module Babylon
  # Instantiated for each stanza
  class Dispatcher

    extend Router
  
    def self.priority
      @priority ||= 0
      @priority
    end
    def self.priority=(p)
      @priority = p
    end

    ##
    # Claim stanzas matching `matches' for this Dispatcher. 
    def self.claim(matches = {})
      route = Route.new(priority, matches) do |connection,stanza,dispatcher_bindings|
        route(connection, stanza, dispatcher_bindings)
      end
      CentralRouter.add_route route
    end

    ##
    # Map XPath `matches' to a method. Beware that stanzas still fall
    # through to the next dispatcher if no method caught it with
    # route_to.
    def self.route_to(handler_method, matches = {})
      method_route = Route.new(0, matches) do |connection,stanza,method_bindings,dispatcher_bindings|
        i = new(*dispatcher_bindings)
        i.instance_variable_set :@connection, connection
        i.instance_variable_set :@stanza, stanza
        i.send(handler_method, *method_bindings)
      end
      add_route method_route
    end

    ##
    # Send XML (or String) on the connection of the incoming stanza
    def send_xml(xml)
      @connection.send xml
    end
  
  end
end
