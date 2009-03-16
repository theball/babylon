module Babylon
  module Base
    
    ##
    # Your application's views (stanzas) should be descendant of this class.
    class View 
      attr_reader :output, :view_template
      
      ##
      # Instantiate a new view with the various varibales passed in assigns and the path of the template to render.
      def initialize(path, assigns)
        @output = ""
        @view_template = path
        assigns.each do |key, value| 
          instance_variable_set("@#{key}", value)
          self.class.send(:define_method, key) do # Defining accessors
            value
          end
        end
      end
      
      ##
      # "Loads" the view file, and uses the Nokogiri Builder to build the XML stanzas that will be sent.
      def evaluate
        str = File.read(@view_template)
        xml = Nokogiri::XML::Builder.new do
          instance_eval(str)
        end
        return xml.doc.children #we return the doc's children (to avoid the instruct)
      end
      
    end 
  end 
end
