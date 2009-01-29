$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rexml/element'
require 'rexml/document'
require 'babylon/dispatcher'
require 'babylon/runner'
require 'babylon/xmpp_handler'
require 'babylon/base/controller'

module Babylon
  VERSION = '0.0.1'
  
end

