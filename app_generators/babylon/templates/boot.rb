require 'rubygems'
require 'babylon'

# Loading the config file
config = YAML.load(File.open("config.yaml", 'r'))[ENV["BABYLON_ENV"] || "development"]

# Loading the controllers
controllers = Array.new
Dir.glob(File.join(File.dirname(__FILE__), '*_controller.rb')).each do |file|
  require file
  klass = file.capitalize.gsub(/.rb$/, '').gsub(/.\//, '').camelize
  controllers << Kernel.const_get(klass).new
end

Babylon::Runner.run(config, controllers)