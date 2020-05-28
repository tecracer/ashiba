require 'yaml'
# require_relative 'template_loaders/*.rb'

# Namespace of Ashiba
module Ashiba
  # Loads templates and creates the Template object.
  class TemplateLoader
    # Return all locations to look for configuration files.
    #
    # @return [Array] Possible paths for configuration
    def locations
      dirs = []

      # Add any templates in plugin packs
      template_gems = Gem::Specification.latest_specs(true).select { |g| g.name =~ /^ashiba-/ }
      template_gems.each do |spec|
        dirs << File.join(spec.base_dir, 'gems', "#{spec.name}-#{spec.version}", 'templates')
      end

      # Bundled templates last, so they can be overridden by identically named gems
      dirs << File.expand_path('../../templates', __dir__)
    end

    # Search for given template in all known locations. May be
    # given a path as well, to directly reference a file
    #
    # @param [String] Name/Path of template
    # @return [String] Full path of the template, if found
    # @raise [SomeError] If no template could be found
    def search_template(name)
      return name if File.file?(name)

      locations.each do |path|
        expected = "#{path}/#{name}.yaml"
        return expected if File.file?(expected)
      end

      raise "Template #{name} not found. Search path: #{locations.join(', ')}"
    end

    # Load the template, including a search in all known locations
    # for templates
    #
    # @param [String] Name/Path of the template
    # @return [Hash] Configuration data, only for compatibility reasons
    # @raise [Error] If file was not found
    # @raise [YAML::SyntaxError] If file was invalid
    def load_template(name)
      config_file = search_template(name)

      begin
        contents = ::YAML.load_file(config_file)
      rescue Errno::ENOENT => e
        puts e.message
      rescue ::YAML::SyntaxError => e
        puts e.message
      end

      # @todo Only for compatibility reasons, should use regular getters later
      contents['origin'] = config_file
      contents

      # @_contents = contents
      # return template
    end

    def template
      Template.new(@_contents)
    end
  end
end
