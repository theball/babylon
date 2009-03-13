require File.dirname(__FILE__) + '/../../spec_helper'

describe Babylon::Runner do
  
  describe ".run" do
    
    def client_mock
      @client_mock ||= 
      begin
        mock(Babylon::ClientConnection)
      end
    end
    
    def component_mock
      @client_mock ||= 
      begin
        mock(Babylon::ComponentConnection)
      end
    end
    
    before(:each) do
      @stub_config_file = File.open(File.dirname(__FILE__) + '/../../../templates/babylon/config/config.yaml') 
      @config = YAML.load(@stub_config_file)
      YAML.stub!(:load).with(@stub_config_file).and_return(@config)
      File.stub!(:open).with('config/config.yaml').and_return(@stub_config_file)
      @callback = Proc.new {
        # Mimick Initializers
      }
      EventMachine.stub!(:run).and_yield
      @client_connection_params = @config["test"].merge({:on_stanza => Babylon::CentralRouter.method(:route)})
      Babylon::ClientConnection.stub!(:connect).with(@client_connection_params).and_return(client_mock)
      Babylon::ComponentConnection.stub!(:connect).with(@client_connection_params).and_return(component_mock)
    end
    
    it "should load the configuration" do
      Babylon::Runner.run("test")
      Babylon.config.should be_a(Hash)
    end
    
    it "should epoll the EventMachine" do
      EventMachine.should_receive(:epoll)
      Babylon::Runner.run("test")
    end
    
    it "should run the EventMachine" do
      EventMachine.should_receive(:run)
      Babylon::Runner.run("test")
    end

    it "should load the configuration file" do
      File.should_receive(:open).with('config/config.yaml').and_return(@stub_config_file)
      Babylon::Runner.run("test")
    end
    
    it "should connect the client connection if specified by the config" do
      @config["test"]["application_type"] = "client"
      Babylon::ClientConnection.should_receive(:connect).with(@client_connection_params.merge({"application_type" => "client"})).and_return(client_mock)
      Babylon::Runner.run("test")
    end
    
    it "should connect the component connection if no application_type specified by the config" do
      Babylon::ComponentConnection.should_receive(:connect).with(@client_connection_params).and_return(component_mock)
      Babylon::Runner.run("test")
    end
    
    it "should require all models" 
    
    it "should require all controllers"
    
    it "should require all routes"
    
    it "should call the callback (it usually contains the initializers)"
    
  end
  
end