$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'babylon/xmpp_connection'
require 'babylon/component_connection'
require 'babylon/router'
require 'babylon/runner'
require 'babylon/base/controller'
require 'babylon/base/view'

module Babylon
  VERSION = '0.0.3'
end

