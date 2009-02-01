#!/usr/bin/env ruby

$: << File.dirname(__FILE__) + "/../../lib/"
require 'babylon'
require 'ramaze/gestalt'

include Babylon

class EchoController
  def echo(s)
    s
  end
end

class EchoDispatcher < Dispatcher
  claim({'self::message' => {
            '@from' => bind(0),
            '@to' => bind(1)
          }})

  def initialize(from, to)
    @from, @to = from, to
    @controller = EchoController.new
  end

  route_to :echo, {
    '@type' => 'chat',
    'string(body)' => bind(0)
  }

  def echo(body)
    # All logic shall go into controllers,
    # dispatchers are for XMPP dismantling and assembly
    reply = @controller.echo(body)

    # Switcheroo: (Gestalt seems to prohibit access to instance variables)
    to, from = @from, @to
    send_xml Ramaze::Gestalt.build {
      message(:from => from,
              :to => to,
              :type => 'chat') {
        body { reply }
      }
    }
  end
end

Runner::run
