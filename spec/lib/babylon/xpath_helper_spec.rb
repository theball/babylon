require File.dirname(__FILE__)+"/../lib/babylon"

describe Babylon::XpathHelper do
  describe "namespace method" do
    before do
      @doc = Nokogiri::XML(<<-eoxml)
        <iq from='me@my.jid/Eee' to='component.my.jid'
        xml:lang='en' type='get' id='43'><query
        xmlns='http://jabber.org/protocol/disco#info'/></iq>
      eoxml
    end

    it "matches nodes of the given name with the given namespace URI" do
      @doc.xpath("//iq/*[namespace(., 'query', 'http://jabber.org/protocol/disco#info')]", Babylon::XpathHelper.new).length.should == 1
    end

    it "does not match a namespace URI if the node names differ" do
      @doc.xpath("//iq/*[namespace(., 'que', 'http://jabber.org/protocol/disco#info')]", Babylon::XpathHelper.new).length.should == 0
    end

    it "does not match a node if the namespace URIs differ" do
      @doc.xpath("//iq/*[namespace(., 'query', 'http://jabber.org/protocol/disco#inf')]", Babylon::XpathHelper.new).length.should == 0
    end
  end
end
