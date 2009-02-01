module Babylon
  module Router
    def prio
      0
    end

    def add_route(route)
      @routes = [] unless @routes
      @routes << route
      @routes.sort! { |r1,r2|
        r2.prio <=> r1.prio
      }
    end

    def route(stanza)
      @routes.each { |route|
        return true if route.route(stanza)
      }
      false
    end
  end

  class Route
    include Router

    def initialize(prio, matches, &handler)
      @prio = prio
      @matches = matches
      @handler = handler
    end

    def route(stanza)
      binding = []
      @matches.each { |expr,expectation|
        first = nil
        REXML::XPath.each(stanza, expr) { |v|
          p v.class
          first = case v
                  when REXML::Attribute
                    v.value
                  when REXML::Element
                    v.text
                  when String
                    v
                  else
                    :unknown_node
                  end
        }
        p [expr, expectation, first]
        if first && expectation.kind_of?(Binding)
          binding[expectation.n] = first
        elsif first == expectation
        else
          return false
        end
      }
      @handler.call *binding
      true
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
