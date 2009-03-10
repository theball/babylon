require File.dirname(__FILE__)+"/../../../lib/babylon"

describe Babylon::Route do
  it "raises an exception if no controller is specified" do
    lambda { Babylon::Route.new("action" => "bar") }.should raise_error(/controller/)
  end

  it "raises an exception if no action is specified" do
    lambda { Babylon::Route.new("controller" => "bar") }.should raise_error(/action/)
  end

end
