module Babylon
  module Base
    class Controller
      
      attr_accessor :stanza, :action_name
      
      def initialize(params = {})
        @stanza = params[:stanza]
        @rendered = false
        @assigns = {}
      end
      
      def perform(action, &block)
        @action_name = action
        @block = block
        self.send(@action_name)
        self.render
      end
      
      
      def render(options = nil, extra_options = {}, &block)
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
      
      def add_variables_to_assigns
        unless @variables_added
          add_instance_variables_to_assigns
          @variables_added = true
        end
      end

      def add_instance_variables_to_assigns
         instance_variables.each do |var|
          @assigns[var[1..-1]] = instance_variable_get(var)
        end
      end
      
      def default_template_name(action_name = self.action_name)
        "app/views/#{self.class.name.gsub("Controller","").downcase}/#{action_name}.xml.builder"
      end
      
      def render_for_file(file)
        view = Babylon::Base::View.new(file, @assigns)
        @block.call(view.evaluate)
      end
      
      
    end
  end
end