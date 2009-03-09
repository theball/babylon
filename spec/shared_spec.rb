# This file contains the shared specifications.
#
module SharedSpec
  
  ##
  # Deactivate the logging
  # Babylon.logger.level = Log4r::FATAL
  
  ##
  # Load configuration from a local config file
  def babylon_config
    @config ||= YAML.load(File.read(File.join(File.dirname(__FILE__), "config.yaml")))
  end
  
end