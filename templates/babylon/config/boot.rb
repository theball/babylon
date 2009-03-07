require "rubygems"
require "babylon"

BABYLON_ENV = ARGV[0] || "development"

# Load the controllers
Dir.glob(File.join(File.dirname(__FILE__), '../app/controllers/*_controller.rb')).each {|f| require f }

# And start the App
Babylon::Runner::run() {
  # And the initializers, too. This is done here since some initializers might need EventMachine to be started.
  Dir.glob(File.join(File.dirname(__FILE__), '/initializers/*.rb')).each {|f| require f }
}
