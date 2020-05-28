require 'hashie'
require 'yaml'

# Namespace of Ashiba
module Ashiba
  # Class loading and representing all configuration data independent
  # of chosen templates
  #
  # @attr [Hashie::Mash] settings Loaded settings
  class Configuration
    attr_accessor :settings

    # Initialize class
    def initialize
      @settings = Hashie::Mash.new
    end

    # Return all locations to look for configuration files.
    #
    # @return [Array] Possible paths for configuration
    def locations
      [
        '/etc/ashiba/fashibarc',
        "#{ENV['HOME']}/.ashibarc"
      ]
    end

    # Load values from stated file and merge over previously loaded data,
    # allowing stacking of global + personal configuration
    #
    # @param [String] filename
    # @return [void]
    def process_config(file)
      $logger.debug("Processing user configuraton file #{file}")

      begin
        contents = ::YAML.load_file(file)
      rescue Errno::ENOENT => e
        puts e.message
      rescue ::YAML::SyntaxError => e
        puts e.message
      end

      new_settings = Hashie::Mash.new(contents)
      new_settings.each { |k, v| $logger.debug("  Setting #{k} to #{v}") }

      @settings.deep_merge!(new_settings)
    end

    # Recurse over possible locations for configuration and stack found
    # values
    #
    # @return [Hash] Summary of settings
    def load
      $logger.info('Loading configuration')

      locations.each do |config|
        $logger.debug("Checking for configuration at #{config}")
        next unless File.file?(config)

        process_config(config)
      end

      $logger.debug('Evaluated configuration as:')
      @settings.each { |k, v| $logger.debug("  Setting #{k} to #{v}") }

      @settings.to_hash # @todo just for compatibility with old codebase
    end
  end
end
