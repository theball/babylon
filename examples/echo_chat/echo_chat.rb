#!/usr/bin/env ruby

$: << File.dirname(__FILE__) + "/../../lib/"
require 'babylon'
require 'ramaze/gestalt'

include Babylon

##
# This controller does really nothing but serves the purpose of
# showing that dispatchers and controllers should always be seperate.
class EchoController
  def echo(s)
    s
  end
end

class EchoDispatcher < Dispatcher
  ##
  # Stanzas matching this will be routed to this dispatcher's methods
  claim({'self::message' => {
            '@from' => bind(0),
            '@to' => bind(1)
          }})
  # from & to are bound by claim
  def initialize(from, to)
    @from, @to = from, to
    @controller = EchoController.new
  end

  ##
  # Route stanzas matching this to the echo method
  route_to :echo, {
    '@type' => 'chat',
    'string(body)' => bind(0)
  }
  # body is bound by the bind(0) in route_to
  def echo(body)
    # All logic shall go into controllers,
    # dispatchers are for XMPP dismantling and assembly
    reply = @controller.echo(body)

    # Switcheroo:
    to, from = @from, @to
    # (Gestalt seems to prohibit access to instance variables)
    send_xml Ramaze::Gestalt.build {
      message(:from => from,
              :to => to,
              :type => 'chat') {
        body { reply }
      }
    }
  end
end

# Finally, run with the default ./config.yaml location
Runner::run
