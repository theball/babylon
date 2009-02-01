require 'digest/sha1'

module Babylon
  class Dispatcher

    extend Router
  
    def self.priority
      @priority ||= 0
      @priority
    end
    def self.priority=(p)
      @priority = p
    end

    def self.claim(matches = {})
      route = Route.new(priority, matches) do |connection,stanza,dispatcher_bindings|
        route(connection, stanza, dispatcher_bindings)
      end
      CentralRouter.add_route route
    end

    def self.route_to(handler_method, matches = {})
      method_route = Route.new(0, matches) do |connection,stanza,method_bindings,dispatcher_bindings|
        i = new(*dispatcher_bindings)
        i.instance_variable_set :@connection, connection
        i.instance_variable_set :@stanza, stanza
        i.send(handler_method, *method_bindings)
      end
      add_route method_route
    end

    def send_xml(xml)
      @connection.send xml
    end
  
  end
end
