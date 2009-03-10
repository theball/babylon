require "rubygems"
require "lib/babylon"
require "spec/shared_spec.rb"

describe Babylon::ClientConnection do
  
  include SharedSpec
  
  before(:each) do
    @on_stanza = Proc.new {
      
    }
    Babylon.config = babylon_config["client"]
  end
  
  it "should connect with the right parameters" do
    EventMachine.run do
      Babylon::ClientConnection.connect(babylon_config["client"].merge({:on_stanza => @on_stanza})) do |connection|
        connection.should be_true
        EM.stop_event_loop
      end 
    end 
  end 
  
  it "should not connect with the wrong password and raise an error" do 
    Babylon.config["password"] = "wrong_password"
    lambda { 
    EventMachine.run do 
      Babylon::ClientConnection.connect(babylon_config["client"].merge({:on_stanza => @on_stanza})) do |connection|
        EventMachine.stop_event_loop
      end 
    end }.should raise_error(Babylon::AuthenticationError) 
  end
  
end