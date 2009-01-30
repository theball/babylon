require 'babylon'
require 'spec'

include Babylon

describe ComponentDispatcher do
  def parse_xml(s)
    REXML::Document.new(s).root
  end

  before :each do
    @component = ComponentDispatcher.new('jid' => 'component.example.com',
                                         'password' => 'secret')
  end

  it 'should send correct document root tag' do
    handler = mock('handler')

    handler.should_receive(:send_data).
      with(/^<stream:stream /).
      with(/ xmlns=['"]jabber:component:accept['"]/).
      with(/ xmlns:stream=['"]http:\/\/etherx.jabber.org\/streams['"]/).
      with(/ to=['"]component.example.com['"]/)
    @component.start_streaming(handler)
  end

  it 'should authenticate' do
    ID = 'foobar'
    handler = mock('handler')

    sent = 0
    handler.should_receive(:send_data) { |handshake|
      sent += 1
      if sent == 2
        hash = Digest::SHA1::hexdigest(ID + 'secret')
        handshake.to_s.should match(/^<handshake.*?>#{hash}<\/handshake>/)
      end
    }.twice

    @component.start_streaming(handler)
    @component.dispatch parse_xml("
<stream:stream xmlns='jabber:component:accept'
               xmlns:stream='http://etherx.jabber.org/streams'
               id='#{ID}' from='example.com'/>
")
  end
end
