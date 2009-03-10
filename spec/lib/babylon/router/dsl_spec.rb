require File.dirname(__FILE__)+"/../../../../lib/babylon"

describe Babylon::Router::DSL do
  before(:each) do
    Babylon::CentralRouter.purge_routes!
    class ControllerController; end
  end

  it "raises an exception if the route lacks a controller" do
    lambda { Babylon::CentralRouter.draw do
      xpath("/test").to(:action => "foo")
    end }.should raise_error(/controller/)
  end

  it "raises an exception if the route lacksan action" do
    lambda { Babylon::CentralRouter.draw do
      xpath("/test").to(:controller => "foo")
    end }.should raise_error(/action/)
  end

  it "raises an exception if the route has no destination" do
    lambda { Babylon::CentralRouter.draw do
      xpath("//test")
    end }.should raise_error(/destination/)
  end

  it "creates a route with the specified xpath, controller and action" do
    Babylon::CentralRouter.draw do
      xpath("//test"
      ).to(:controller => "controller", :action => "action")
    end
    routes = Babylon::CentralRouter.instance_variable_get("@routes")
    routes.length.should == 1
  end

  describe :disco_info do
    it "matches the root disco#info namespace" do
      Babylon::CentralRouter.draw do
        disco_info.to(:controller => "controller", :action => "action")
      end
      route = Babylon::CentralRouter.instance_variable_get("@routes").last
      route.xpath.should == "//iq[@type='get']/*[namespace(., 'query', 'http://jabber.org/protocol/disco#info')]"
    end

    it "matches the disco#info namespace for the specified node" do
      Babylon::CentralRouter.draw do
        disco_info("test").to(:controller => "controller", :action => "action")
      end
      route = Babylon::CentralRouter.instance_variable_get("@routes").last
      route.xpath.should == "//iq[@type='get']/*[namespace(., 'query', 'http://jabber.org/protocol/disco#info') and @node = 'test']"
    end
  end

  describe :disco_items do
    it "matches the root disco#items namespace" do
      Babylon::CentralRouter.draw do
        disco_items.to(:controller => "controller", :action => "action")
      end
      route = Babylon::CentralRouter.instance_variable_get("@routes").last
      route.xpath.should == "//iq[@type='get']/*[namespace(., 'query', 'http://jabber.org/protocol/disco#items')]"
    end

    it "matches the disco#items namespace for the specified node" do
      Babylon::CentralRouter.draw do
        disco_items("test").to(:controller => "controller", :action => "action")
      end
      route = Babylon::CentralRouter.instance_variable_get("@routes").last
      route.xpath.should == "//iq[@type='get']/*[namespace(., 'query', 'http://jabber.org/protocol/disco#items') and @node = 'test']"
    end
  end
end
