module Babylon
  
  class Runner
    require 'eventmachine'
    
    def self.run(config, controllers)
      EventMachine.epoll
      EventMachine::run do
          # Loading The config.yaml 
          dispatcher = (config['dispatcher'] || Babylon::ComponentDispatcher).new(config, controllers)
          EventMachine::connect config["host"], config["port"], Babylon::XmppHandler, config.merge({:dispatcher => dispatcher})
      end
    end
  
  end
end
