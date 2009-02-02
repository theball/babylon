module Babylon
  module Router
    # Insert a route sorted
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
    def route(connection, stanza, *context)
      @routes ||= []
      @routes.each { |route|
        return true if route.route(connection, stanza, *context)
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
    attr_reader :priority

    def initialize(priority, matches, &handler)
      @priority = priority
      @matches = matches
      @handler = handler
    end

    def route(connection, stanza, *context)
      binding = Route::match(stanza, @matches)
      if binding == false
        false
      else
        @handler.call connection, stanza, binding, *context
        true
      end
    end

    def self.match(xml, matches)
      binding = []
      matches.each { |expr,expectation|
        match = REXML::XPath.first(xml, expr)
        return false unless match

        match_value = case match
                      when REXML::Attribute
                        match.value
                      when REXML::Element
                        match
                      when String, Fixnum
                        match
                      else
                        :unknown
                      end

        case expectation
        when Binding
          binding[expectation.n] = match_value
        when Hash
          subbinding = match(match, expectation)
          subbinding.each_with_index { |value,i|
            binding[i] = value if value
          }
        else
          return false unless match_value.to_s == expectation.to_s
        end
      }
      binding
    end
  end

  # To be used as a value in a `matches' hash. Binds the match's value
  # to the n position in the bindings array returned by Route::match.
  def bind(n)
    Binding.new(n)
  end
  class Binding # :nodoc:
    attr_reader :n
    def initialize(n)
      @n = n
    end
  end
end
