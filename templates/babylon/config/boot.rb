require "rubygems"
require "babylon"
require File.dirname(__FILE__)+"/dependencies"

BABYLON_ENV = ARGV[0] || "development"

# Start the App
Babylon::Runner::run(BABYLON_ENV) do
  # And the initializers, too. This is done here since some initializers might need EventMachine to be started.
  Dir[File.join(File.dirname(__FILE__), '/initializers/*.rb')].each {|f| require f }
end
