module Babylon
  
  class Runner
    require 'eventmachine'
    
    def self.run(config=nil)
      config = YAML::load(File.new('config.yaml')) unless config
      @@run = true

      EventMachine.epoll
      EventMachine::run do
        connection = (config['connection'] || Babylon::ComponentConnection)
        connection.connect(config)
      end
    end

=begin
    # Like in RSpec's spec/runner.rb
    @@at_exit_hook_registered ||= false
    unless @@at_exit_hook_registered
      at_exit do
        @@run ||= false
        unless @@run
          config = YAML::load(File.new('config.yaml'))
          run(config)
        end
      end
      @@at_exit_hook_registered = true
    end
=end
  
  end
end
