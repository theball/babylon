require "rubygems"
require "babylon"

# Load the controllers
Dir.glob(File.join(File.dirname(__FILE__), '../app/controllers/*_controller.rb')).each {|f| require f }

# And the initializers, too.
Dir.glob(File.join(File.dirname(__FILE__), '/initializers/*.rb')).each {|f| require f }

# And start the App
Babylon::Runner::run()
