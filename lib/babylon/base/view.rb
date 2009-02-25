module Babylon
  module Base
    
    # Your application's views should be descendant of this class.
    
    class View
      
      attr_reader :output 
      
      # Instantiate a new view with the various varibales passed in assigns and the path of the template to render.
      def initialize(path, assigns)
        @assigns = assigns
        @output = ""
        @view_template = path
      end
      
      # "Loads" the view file, and uses the Nokogiri Builder to build the XML stanzas that will be sent.
      def evaluate 
        evaluate_assigns
        view_content = File.read(@view_template)
        xml = Nokogiri::XML::Builder.new do
          instance_eval(view_content)
        end
        return xml.doc.root.to_xml #we return the doc's root (to avoid the instruct)
      end
      
      # Evaluate the local assigns and pushes them to the view.
      def evaluate_assigns
        unless @assigns_added
          assign_variables_from_controller
          @assigns_added = true
        end
      end
      
      # Assigns instance variables from the controller to the view.
      def assign_variables_from_controller
        @assigns.each do |key, value| 
          instance_variable_set("@#{key}", value)
          self.class.send(:define_method, key) do
            value
          end
        end
      end
      
    end 
  end 
end