module Babylon
  module Base
    
    # Your application's controller should be descendant of this class.
    
    class Controller
      
      attr_accessor :stanza # Stanza received by the controller (Nokogiri::XML::Node)
      
      # Creates a new controller (you should not override this class) and assigns the stanza
      def initialize(params = {})
        @stanza = params[:stanza]
        @rendered = false
        @assigns = {}
      end
      
      # Performs the action and calls back the optional block argument : you should not override this function
      def perform(action, &block)
        @action_name = action
        @block = block
        self.send(@action_name)
        self.render
      end
      
      # Called by default after each action to "build" a XMPP stanza. By default, it will use the /controller_name/action.xml.builder
      def render(options = nil)
        return if @rendered # Avoid double rendering
        
        add_variables_to_assigns # Assign variables
        
        if options.nil? # default rendering
          return render(:file => default_template_name)
        elsif action_name = options[:action]
          return render(:file => default_template_name(action_name.to_s))
        end
        render_for_file(options[:file]) 
        
        # And finally, we set up rendered to be true 
        @rendered = true
      end
      
      protected
      
      # Used to transfer the assigned variables from the controller to the views
      def add_variables_to_assigns
        unless @variables_added
          add_instance_variables_to_assigns
          @variables_added = true
        end
      end

      # Used to transfer the assigned variables from the controller to the views
      def add_instance_variables_to_assigns
         instance_variables.each do |var|
          @assigns[var[1..-1]] = instance_variable_get(var)
        end
      end
      
      # Default template name used to build stanzas
      def default_template_name(action_name = self.action_name)
        "app/views/#{self.class.name.gsub("Controller","").downcase}/#{action_name}.xml.builder"
      end
      
      # Creates the view and "evaluates" it to build the XML for the stanza
      def render_for_file(file)
        view = Babylon::Base::View.new(file, @assigns)
        @block.call(view.evaluate)
      end
    end
  end
end