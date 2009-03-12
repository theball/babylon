module Babylon
  module Base
    
    ##
    # Your application's controller should be descendant of this class.
    class Controller
      
      attr_accessor :stanza, :rendered, :action_name # Stanza received by the controller (Nokogiri::XML::Node)
      
      ##
      # Creates a new controller (you should not override this class) and assigns the stanza as well as any other value of the hash to instances named after the keys of the hash.
      def initialize(params = {})
        params.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
        @rendered = false
      end
      
      ##
      # Performs the action and calls back the optional block argument : you should not override this function
      def perform(action, &block)
        @action_name = action
        @block = block
        begin
          self.send(@action_name)
        rescue
          Babylon.logger.error("#{$!}:\n#{$!.backtrace.join("\n")}")
        end
        self.render
      end
      
      ##
      # Called by default after each action to "build" a XMPP stanza. By default, it will use the /controller_name/action.xml.builder
      def render(options = nil)
        return if @rendered # Avoid double rendering
        
        if options.nil? # default rendering
          return render(:file => default_template_name)
        elsif options[:file]
          render_for_file(view_path(options[:file])) 
        elsif action_name = options[:action]
          return render(:file => default_template_name(action_name.to_s))
        end
        
        # And finally, we set up rendered to be true 
        @rendered = true
      end
      
      protected

      # Used to transfer the assigned variables from the controller to the views
      def hashed_variables
        vars = Hash.new
         instance_variables.each do |var|
          vars[var[1..-1]] = instance_variable_get(var)
        end
        return vars
      end
      
      def view_path(file_name)
        File.join("app/views", "#{self.class.name.gsub("Controller","").downcase}", file_name)
      end
      
      # Default template name used to build stanzas
      def default_template_name(action_name = nil)
        return "#{action_name || @action_name}.xml.builder"
      end
      
      # Creates the view and "evaluates" it to build the XML for the stanza
      def render_for_file(file)
        Babylon.logger.info("RENDERING : #{file}")
        @block.call(Babylon::Base::View.new(file, hashed_variables).evaluate) if @block
      end
    end
  end
end