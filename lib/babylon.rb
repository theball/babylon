$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'eventmachine'
require "log4r"
require 'nokogiri'
require "yaml"

require 'babylon/xmpp_connection.rb'
require 'babylon/component_connection.rb'
require 'babylon/client_connection.rb'
require 'babylon/router.rb'
require 'babylon/runner.rb'
require 'babylon/base/controller.rb'
require 'babylon/base/view.rb'

# Babylon is a XMPP Component Framework based on EventMachine. It uses the Nokogiri GEM, which is a Ruby wrapper for Libxml2.
# It implements the MVC paradigm.
# You can create your own application by running :
#   $> babylon app_name
# This will generate some folders and files for your application. Please see README for further instructions

module Babylon
  # 0.0.5 : Not suited for production, use at your own risks
  VERSION = '0.0.5'

  ##
  # Returns a shared logger for this component.
  def self.logger
    unless self.class_variable_defined?("@@logger")
      @@logger = Log4r::Logger.new("BABYLON")
      @@logger.add(Log4r::Outputter.stderr)
    end
    @@logger
  end

  ##
  # Set the configuration for this component.
  def self.config=(conf)
    @@config = conf
  end

  ##
  # Return the configuration for this component.
  def self.config
    @@config
  end
  
  ##
  # Authentication Error (wrong password/jid combination). Used for Clients and Components
  class AuthenticationError < Exception 
  end
  
end

