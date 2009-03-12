require File.dirname(__FILE__) + '/../../../spec_helper'

describe Babylon::Base::Controller do

  before(:each) do
    File.stub!(:read).and_return("") # Stubbing read for view
  end
  
  describe ".initialize" do
    before(:each) do
      @params = {:a => "a", :b => 1, :c => {:key => "value"}, :stanza => "<hello>world</hello>"}    
    end
    
    it "should have instances for each pair of the hash passed for initailization" do
      c = Babylon::Base::Controller.new(@params)
      
      @params.each do |key, value|
        c.instance_variables.should be_include "@#{key}"
        c.instance_variable_get("@#{key}").should == value
      end
    end
    
    it "should not be rendered yet" do
      c = Babylon::Base::Controller.new(@params)
      c.rendered.should_not be_true
    end
  end
  
  describe ".perform" do
    before(:each) do
      params = {:stanza => "<hello>world</hello>"}
      @controller = Babylon::Base::Controller.new(params)
    end
    
    it "should setup the action to the param" do
      action = :subscribe
      @controller.perform(action) do
        # Do something
      end
      @controller.instance_variable_get("@action_name").should == action
    end

    it "should assign the block" do
      block = Proc.new {
        # Do something
      }
      @controller.perform(:subscribe, &block) 
      @controller.instance_variable_get("@block").should == block
    end
    
    it "should call the action" do
      action = :subscribe
      @controller.should_receive(:send).with(action).and_return()
      @controller.perform(action) do
        # Do something
      end
    end
    
    it "should write an error to the log in case of failure of the action" do
      action = :subscribe
      @controller.stub!(:send).with(action).and_raise(StandardError)
      Babylon.logger.should_receive(:error)
      @controller.perform(action) do
        # Do something
      end
    end
    
    it "should call render" do
      action = :subscribe
      @controller.should_receive(:render)
      @controller.perform(action) do
        # Do something
      end
    end
  end
  
  describe ".render" do
    before(:each) do
      @controller = Babylon::Base::Controller.new({})
      @controller.action_name = :subscribe
    end
    
    it "should set rendered to true" do
      @controller.render
      @controller.rendered.should be_true
    end
    
    it "should call render with default_file_name if no option is provided" do
      @controller.should_receive(:default_template_name)
      @controller.render      
    end
    
    it "should call render with the file name corresponding to the action given as option" do
      action = :unsubscribe
      @controller.should_receive(:default_template_name).with("#{action}")
      @controller.render(:action => action)
    end
    
    it "should call render_for_file with the correct path if an option file is provided" do
      file = "myfile"
      @controller.should_receive(:render_for_file)
      @controller.render(:file => file)
    end
    
    it "should render twice when called twice" do
      @controller.render
      @controller.should_not_receive(:render_for_file)
      @controller.render      
    end
    
  end

  describe ".hashed_variables" do
    it "should return an hash containing all instance variables" do
      @controller = Babylon::Base::Controller.new()
      vars = Hash.new
       @controller.instance_variables.each do |var|
        vars[var[1..-1]] = @controller.instance_variable_get(var)
      end
      @controller.hashed_variables.should == vars
    end
  end

  describe ".view_path" do
    it "should return complete file path to the file given in param" do
      @controller = Babylon::Base::Controller.new()
      @controller.view_path("myfile").should == File.join("app/views", "#{"Babylon::Base::Controller".gsub("Controller","").downcase}", file_name)
    end
  end
  
  describe ".default_template_name" do
    before(:each) do
      @controller = Babylon::Base::Controller.new()
    end
    
    it "should return the view file name if a file is given in param" do
      @controller.default_template_name("myaction").should_equal "myaction.xml.builder"
    end
    
    it "should return the view file name based on the action_name if no file has been given" do
      @controller.action_name = "a_great_action"
      @controller.default_template_name.should_equal "a_great_action.xml.builder"
    end
  end
  
  describe ".render_for_file" do
    
    before(:each) do
      @controller = Babylon::Base::Controller.new()
      @block = Proc.new {
        # Do something
      }
      @controller.perform(:action, &@block) 
      @view = Babylon::Base::View.new("path_to_a_file", {})
    end
    
    it "should display a INFO message to the Babylon log" do
      Babylon.logger.should_receive(:info)
      @controller.render_for_file("path_to_a_file")
    end
    
    it "should instantiate a new view, with the file provided and the hashed_variables" do
      Babylon::Base::View.should_receive(:new).with("path_to_a_file",an_instance_of(Hash)).and_return(@view)
      @controller.render_for_file("path_to_a_file")
    end
    
    it "should evaluate the newly instantiated view" do
      Babylon::Base::View.stub!(:new).with("path_to_a_file",an_instance_of(Hash)).and_return(@view)
      view.should_receive(:evaluate).and_return("")
      @controller.render_for_file("path_to_a_file")
    end
    
    it "should call the block with the result of the evaluation of the view if @block is set" do
      @block.should_receive(:call).with(@view.evaluate)
      @controller.render_for_file("path_to_a_file")
    end
    
  end

end