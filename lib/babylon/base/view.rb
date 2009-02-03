module Babylon
  module Base
    class View

      attr_accessor :assigns
      attr_reader :output 

      def initialize(params)
        @output = ""
        @view_template = "app/views/#{params[:controller]}/#{params[:action]}.xml.builder"
      end

      def evaluate
        evaluate_assigns
        xml = Builder::XmlMarkup.new(:target => @output)
        instance_eval(IO::readlines(@view_template).to_s)
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
        @assigns.each { |key, value| instance_variable_set("@#{key}", value) }
      end

    end    
  end
end