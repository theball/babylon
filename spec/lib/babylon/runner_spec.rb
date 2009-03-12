require File.dirname(__FILE__) + '/../../spec_helper'

describe Babylon::Runner do
  
  describe ".run" do
    it "should epoll the EventMachine" do
      EventMachine.should_receive(:epoll)
      EventMachine.should_receive(:run)
      Babylon::Runner.run
    end
    
    it "should run the EventMachine"

    it "should load the configuration file"
    
    it "should prepare the params for the connection"
    
    describe "connection params" do
      it "should contain 2 element, the fist one being an Array and the second one being a Proc"
      
      it "should have its first element (the hash) contain :on_stanza pointing to a Proc (the CentralRouter's route method)"
      
      it "should have its 2nd elementbe a Proc (the CentralRouter's connected method)"
      
    end
    
    it "should connect the right connection, based on config"
    
    it "should require all models"
    
    it "should require all controllers"
    
    it "should require all routes"
    
    it "should call the callback (it usually contains the initializers)"
    
  end
  
end