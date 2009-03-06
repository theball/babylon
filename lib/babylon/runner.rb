module Babylon
  
  ##
  # Runner is in charge of running the application.
  class Runner

    ##
    # When run is called, it loads the configuration, the routes and add them into the router
    # It then loads the models.
    # Finally it starts the EventMachine and connect the ComponentConnection
    # You can pass an additional block that will be called upon launching, when the eventmachine has been started.
    def self.run(env = "development", &callback) 
      Babylon.config = YAML::load(File.new('config/config.yaml'))[env] 
      routes = YAML::load(File.new('config/routes.yaml')) || [] 
      
      # Adding Routes
      CentralRouter.add_routes(routes)
      
      # Requiring all models
      Dir.glob('app/models/*.rb').each do |f| 
        require f 
      end
      
      # Starting the EventMachine
      EventMachine.epoll
      EventMachine::run do
        Babylon::ComponentConnection.connect
        
        # And finally, let's allow the application to do all it wants to do after we started the EventMachine!
        callback.call if callback
      end
    end
    
  end
end
