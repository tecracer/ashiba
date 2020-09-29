require 'hashie'
require 'highline'
require 'thor'
require 'yaml'

module Ashiba
  class TemplateVariable
    attr_accessor :name, :value, :type, :default, :mandatory

    # ok this is bugged
    def initialize(name = '', value = '', type = 'String', default = '', mandatory = false)
      @name = name
      @value = value
      @type = type
      @default = default
      @mandatory = mandatory
    end

    def to_s
      "#{name}=#{value} of type #{type}, defaulting to #{default} and mandatory is #{mandatory}"
    end
  end

  class Cli < Thor
    include Thor::Actions
    check_unknown_options!
    # add_runtime_options!

    def self.source_root
      # File.dirname(__FILE__)
      File.expand_path('../../templates', __dir__)
    end

    def self.exit_on_failure?
      true
    end

    map %w[version] => :__print_version
    desc 'version', 'Display version'
    def __print_version
      say "Ashiba #{VERSION} (Ruby #{RUBY_VERSION}-#{RUBY_PLATFORM})"
    end

    @packdata = {}
    attr_accessor :packdata

    @config = {}
    attr_accessor :config

    no_commands do
      def get_data_from_template(name)
        TemplateLoader.new.load_template(name)
      end

      def load_data_from_userconfig
        @config = Configuration.new
        @config.load
      end

      # @todo
      @template_information = {}
      def process_template_information(template)
        template_info = get_data_from_template(template)
        template_info = template_info.delete('variables')
        @template_information = Hashie::Mash.new(template_info)
      end

      def template_information(key)
        @template_information.fetch(key)
      end

      # @todo
      @template_variables = {}
      def process_template_variables(_template, variables)
        # template_info = get_data_from_template(template)
        # @todo unifying structure, ideally struct class?
        # variables = Hashie::Mash.new(template_info['variables'])
        variables = Hashie::Mash.new(variables)

        variables.each do |k, v|
          if v.is_a?(String)
            TemplateVariable.new(name: k, value: v)
            # Results in #<struct TemplateVariable name={:name=>"email", :value=>"theinen@tecracer.de"}, value=""
          elsif v.is_a?(Hashie::Mash)
            # puts TemplateVariable.new(name: k, **v)
            # Explodes like a Pro
          else
            raise "No known datatype for variable #{k}"
          end
        end
      end

      def parse_template_data(template)
        template_info = get_data_from_template(template)

        # Template defaults, then config files, then command line
        defaults = Hashie::Mash.new(template_info['variables'])
        defaults.deep_update(load_data_from_userconfig)
        defaults.deep_update(options['set'])

        # For ease of use: if no 'name' was passed, use the directory name
        defaults['name'] = File.basename(@path) if defaults['name'].empty?

        # Command line query of mandatory arguments
        cli = HighLine.new
        used_cli = false
        defaults.each do |parameter, data|
          next unless data == :mandatory

          puts 'Unset parameters' unless used_cli

          defaults[parameter] = cli.ask("  #{parameter}: ")
          used_cli = true
        end
        if used_cli
          puts 'Evaluated parameters:'
          defaults.each { |k, v| puts "  #{k}: #{v}" }

          exit unless yes?('Create? [Y/N]')
        end

        process_template_information(template)
        process_template_variables(template, defaults)

        @packdata = defaults
      end

      def retrieve_value(name)
        packdata.fetch(name)
      end

      def dest_filename(filename)
        new_filename = filename.dup
        filename.scan(/%.+?%/) do |placeholder|
          variable = placeholder[1..-2]
          new_filename.gsub!(placeholder, retrieve_value(variable))
        end

        new_filename
      end

      def copy_template(template, path)
        # @todo Really confusing
        template_base = TemplateLoader.new.search_template(template).gsub(/\.yaml$/, '')

        entries = Dir.glob("#{template_base}/**/*", File::FNM_DOTMATCH) - %w[. ..]
        entries.select! { |entry| File.file?(entry) }
        entries.map! { |entry| entry.gsub("#{template_base}/", '') }

        entries.each do |name|
          template("#{template_base}/#{name}", "#{path}/#{dest_filename(name)}")
        end

        template_info = get_data_from_template(template)
        finalize = Array(template_info['finalize'])
        return unless finalize

        Dir.chdir(path) do
          finalize.each { |cmd| puts `#{cmd}` }
        end
      end

      # rubocop:disable Style/MethodMissingSuper,Style/MissingRespondToMissing
      def method_missing(method, *_args, &_block)
        packdata.fetch(method)
      end
      # rubocop:enable Style/MethodMissingSuper,Style/MissingRespondToMissing
    end

    desc 'create TEMPLATE PATH', 'Scaffold a new path'
    method_option :set, desc: 'Values of template to set', type: :hash, default: {}
    def create(template, path)
      path = File.expand_path(path)
      raise Error, set_color("ERROR: #{path} already exists.", :red) if File.exist?(path)

      @path = path
      parse_template_data(template)
      copy_template(template, path)
    end

    desc 'list', 'List available templates'
    def list
      # @todo Should be in TemplateLoader
      dirs = TemplateLoader.new.locations
      entries = []
      dirs.each do |dir|
        yamls = Dir.glob('*.yaml', base: dir)
        basenames = yamls.map { |filename| filename.gsub(/\.yaml$/, '') }

        entries.concat(basenames)
      end

      say 'Available templates:'
      entries.uniq.sort.each do |template|
        data = get_data_from_template(template)
        say "  #{data['name']} (#{data['version']}) - #{data['summary']}"
      end
    end

    desc 'locations', 'List locations to load templates from'
    def locations
      dirs = TemplateLoader.new.locations

      say 'Locations searched for templates'
      dirs.each do |dir|
        say "  #{dir}"
      end
    end

    desc 'info TEMPLATE', 'Get information about a template'
    def info(template)
      load_data_from_userconfig

      template_info = get_data_from_template(template)
      output = <<~OUTPUT
        Name       : #{template_info['name']}
        Version    : #{template_info['version']}
        Description: #{template_info['description'].chop}
        Origin     : #{template_info['origin']}

        Variables:
      OUTPUT
      say output

      align_to = template_info['variables'].keys.map(&:length).max # { |item| item.length }.max
      template_info['variables'].each do |name, default|
        default = '<unset>' if default.empty? || default == :mandatory

        outline =  "  #{name.ljust(align_to)}: "
        outline << "#{@config.settings[name]} (was: #{default})" if config.settings[name]
        outline << default unless config.settings[name]
        say outline
      end
    end
  end
end
