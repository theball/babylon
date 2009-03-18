module Babylon
  
  ##
  # Runner is in charge of running the application.
  class Runner
    
    ##
    # When run is called, it loads the configuration, the routes and add them into the router
    # It then loads the models.
    # Finally it starts the EventMachine and connect the ComponentConnection
    # You can pass an additional block that will be called upon launching, when the eventmachine has been started.
    def self.run(env, &callback)       
      # Starting the EventMachine
      EventMachine.epoll
      EventMachine.run do
        
        # Requiring all models
        Dir.glob('app/models/*.rb').each { |f| require f }

        # Load the controllers
        Dir.glob('app/controllers/*_controller.rb').each {|f| require f }

        #  Require routes defined with the new DSL router.
        require "config/routes" if File.exists?("config/routes.rb")
        
        if env == "production"
          $cached_views = {}
          Dir.glob('app/views/*/*').each do |f|
            $cached_views[f] = File.read(f)
          end
        end
        
        config_file = File.open('config/config.yaml')
        
        Babylon.config = YAML.load(config_file)[env]
        
        params, on_connected = Babylon.config.merge({:on_stanza => Babylon::CentralRouter.method(:route)}), Babylon::CentralRouter.method(:connected)
        
        case Babylon.config["application_type"]
          when "client"
            Babylon::ClientConnection.connect(params, &on_connected)
          else # By default, we assume it's a component
            Babylon::ComponentConnection.connect(params, &on_connected)
        end
        
        # And finally, let's allow the application to do all it wants to do after we started the EventMachine!
        callback.call if callback
      end
    end
    
  end
end
