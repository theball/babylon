require "rubygems"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require File.dirname(__FILE__) + "/../lib/babylon" unless defined? Babylon

# #
# Deactivate the logging
Babylon.logger.level = Log4r::DEBUG

BABYLON_ENV = "test" unless defined? Babylon

module BabylonSpecHelper
  
  ##
  # Load configuration from a local config file
  def babylon_config
    @config ||= YAML.load(File.read(File.join(File.dirname(__FILE__), "config.yaml")))
  end
  
end