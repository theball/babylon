$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'eventmachine'
require 'nokogiri'
require "yaml"

require 'babylon/xmpp_connection'
require 'babylon/component_connection'
require 'babylon/router'
require 'babylon/runner'
require 'babylon/base/controller'
require 'babylon/base/view'

# Babylon is a XMPP Component Framework based on EventMachine. It uses the Nokogiri GEM, which is a Ruby wrapper for Libxml2.
# It implements the MVC paradigm.
# You can create your own application by running :
#   $> babylon app_name
# This will generate some folders and files for your application. Please see README for further instructions

module Babylon
  # 0.0.4 : Not suited for production, use at your own risks
  VERSION = '0.0.4'
end

