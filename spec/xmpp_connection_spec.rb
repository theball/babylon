require "rubygems"
require "lib/babylon.rb"

describe Babylon::XmppConnection do
  
  before(:each) do
    # params = {:debug => false}
    # puts Babylon::VERSION 
    # em_machine_klass_mock = mock(EventMachine::Connection)
    # 
    # EventMachine::Connection.stub!(:connect).and_return(t)
    # 
    # conn = Babylon::XmppConnection.new(params)
    # conn.stub!(:send_data).and_return(true)
  end
  
  describe "connection_completed" do
    it "should do something"
  end
  
end
