require File.dirname(__FILE__) + '/../../spec_helper'

describe Babylon::ComponentConnection do
  
  include BabylonSpecHelper
  
  # before(:each) do
  #   @on_stanza = Proc.new { |stanza|
  #     puts "#{stanza}"
  #   }
  #   Babylon.config = babylon_config["component"]
  # end
  # 
  # it "should connect with the right parameters" do
  #   EventMachine.run do
  #     Babylon::ComponentConnection.connect(Babylon.config.merge({:on_stanza => @on_stanza})) do |connection|
  #       connection.should be_true
  #       EM.stop_event_loop
  #     end 
  #   end 
  # end 
  # 
  # it "should not connect with the wrong password and raise an error" do 
  #   Babylon.config["password"] = "wrong_password"
  #   lambda { 
  #   EventMachine.run do 
  #     Babylon::ComponentConnection.connect(Babylon.config.merge({:on_stanza => @on_stanza})) do |connection|
  #       EventMachine.stop_event_loop
  #     end 
  #   end }.should raise_error(Babylon::AuthenticationError) 
  # end
  # 
  # it "should not connect with a host that is not and xmpp sever and raise an error" do
  #   Babylon.config["host"] = "no_host.com"
  #   lambda {
  #     EventMachine.run do
  #       Babylon::ComponentConnection.connect(Babylon.config.merge({:on_stanza => @on_stanza})) do |connection|
  #         EventMachine.stop_event_loop
  #       end
  #     end }.should raise_error(RuntimeError)     
  # end
  
end