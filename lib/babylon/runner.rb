module Babylon
  
  class Runner
    require 'eventmachine'
    
    def self.run(env = "development")
      config = YAML::load(File.new('config/config.yaml'))[env]
      routes = YAML::load(File.new('config/routes.yaml'))
      
      CentralRouter.add_routes(routes)
      
      # Requireing all models
      Dir.glob('app/models/*.rb').each do |f| 
        puts f
        require f 
      end
      
      EventMachine.epoll
      EventMachine::run do
        Babylon::ComponentConnection.connect(config)
      end
    end
    
  end
end
