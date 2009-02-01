require 'babylon'
require 'xmpp4r/message'
require 'spec'

include Babylon

describe Dispatcher do
  it 'should call for a simple message' do
    CentralRouter.purge_routes!

    $m = mock('callback')
    $m.should_receive(:callback).with(/<message.*\/>/)

    class MyDispatcher1 < Dispatcher
      claim 'self::message' => {}
      route_to :handler
      def handler
        $m.callback(@stanza.to_s)
      end
    end

    CentralRouter.route nil, Jabber::Message.new
  end

  it 'should call with initialized dispatcher' do
    CentralRouter.purge_routes!

    $m = mock('callback')
    $m.should_receive(:callback).with('foo', 'bar', 'Hello')

    class MyDispatcher2 < Dispatcher
      claim 'self::message' => {
        '@from' => bind(0),
        '@to' => bind(1)
      }
      def initialize(from, to)
        @from, @to = from, to
      end

      route_to :handler, 'string(body)' => bind(0)
      def handler(body)
        $m.callback(@from, @to, body)
      end
    end

    CentralRouter.route nil, Jabber::Message.new('bar', 'Hello').set_from('foo')
  end
end
