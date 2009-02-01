module Babylon
  module Router
    def add_route(route)
      @routes ||= []
      @routes << route
      @routes.sort! { |r1,r2|
        r2.priority <=> r1.priority
      }
    end

    def route(stanza, *context)
      @routes ||= []
      @routes.each { |route|
        return true if route.route(stanza, *context)
      }
      false
    end

    def purge_routes!
      @routes = []
    end
  end

  module CentralRouter
    extend Router
  end

  class Route
    include Router

    attr_reader :priority

    def initialize(priority, matches, &handler)
      @priority = priority
      @matches = matches
      @handler = handler
    end

    def route(stanza, *context)
      binding = Route::match(stanza, @matches)
      if binding == false
        false
      else
        @handler.call stanza, binding, *context
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

  def bind(n)
    Binding.new(n)
  end
  class Binding
    attr_reader :n
    def initialize(n)
      @n = n
    end
  end
end
