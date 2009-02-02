require 'babylon'
require 'xmpp4r/message'
require 'spec'

include Babylon

class StubRouter
  include Router
end

describe Router do
  it 'should call for a simple pattern' do
    m = mock('callback')
    m.should_receive(:callback)
    r = StubRouter.new
    r.add_route Route.new(0,
                          {'@type' => 'chat'},
                          &m.method(:callback))
    r.route Jabber::Message.new.set_type(:chat)
  end
  it 'should call for a more complex pattern' do
    m = mock('callback')
    m.should_receive(:callback)
    r = StubRouter.new
    r.add_route Route.new(0,
                          {'@type' => 'chat',
                            'string(body)' => 'Hello'},
                          &m.method(:callback))
    r.route Jabber::Message.new(nil, 'Hello').set_type(:chat)
  end
  it 'should call with a binding' do
    m = mock('callback')
    m.should_receive(:callback).with('chat', 'Hello')
    r = StubRouter.new
    r.add_route Route.new(0,
                          {'@type' => bind(0),
                            'string(body)' => bind(1)},
                          &m.method(:callback))
    r.route Jabber::Message.new(nil, 'Hello').set_type(:chat)
  end
  it 'should not call non-matching routes' do
    m = mock('callback')
    m.should_receive(:callback).never
    r = StubRouter.new
    r.add_route Route.new(0,
                          {'@type' => 'chat'},
                          &m.method(:callback))
    r.route Jabber::Message.new
  end
  it 'should call with a recursive binding' do
    m = mock('callback')
    m.should_receive(:callback).with('chat', 'Hello')
    r = StubRouter.new
    r.add_route Route.new(0,
                          {'self::message' => {
                              '@type' => bind(0),
                              'body' => {'string(.)' => bind(1)}}},
                          &m.method(:callback))
    r.route Jabber::Message.new(nil, 'Hello').set_type(:chat)
  end
end
