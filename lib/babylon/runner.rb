module Babylon
  
  ##
  # Runner is in charge of running the application.
  class Runner

    ##
    # When run is called, it loads the configuration, the routes and add them into the router
    # It then loads the models.
    # Finally it starts the EventMachine and connect the ComponentConnection
    # You can pass an additional block that will be called upon launching, when the eventmachine has been started.
    def self.run(&callback) 
      Babylon.config = YAML::load(File.new('config/config.yaml'))[BABYLON_ENV] 
      if File.exist?("config/routes.yml")
        routes = YAML::load(File.new('config/routes.yaml')) || []
        # Adding Routes
        CentralRouter.add_routes(routes)
      else # New DSL router.
        require "config/routes"
      end
      # Requiring all models
      Dir.glob('app/models/*.rb').each { |f| require f }
      
      # Starting the EventMachine
      EventMachine.epoll
      EventMachine::run do
        on_stanza = Proc.new { |stanza|
          CentralRouter.route(stanza) # Upon reception of new stanza, we Route them through the controller
        }
        if Babylon.config["application_type"] && Babylon.config["application_type"] == "client"
          Babylon::ClientConnection.connect({:on_stanza => on_stanza}) do |connection|
            # Awesome, we're now connected and authentified, let's tell the CentralRouter we're connecter
            CentralRouter.connected(connection)
          end
        else
          Babylon::ComponentConnection.connect({:on_stanza => on_stanza}) do |connection|
            # Awesome, we're now connected and authentified, let's tell the CentralRouter we're connecter
            CentralRouter.connected(connection)
          end
        end
        # And finally, let's allow the application to do all it wants to do after we started the EventMachine!
        callback.call if callback
      end
    end
    
  end
end
