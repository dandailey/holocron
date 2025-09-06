# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'colorize'

module Holocron
  class ConfigManager
    CONFIG_FILENAME = '.holocron_base.yml'

    VALID_HOLOCRON_TYPES = %w[base app project].freeze
    VALID_CONTRIBUTE_MODES = %w[local github_issue github_pr disabled].freeze

    def initialize(directory = '.')
      @directory = File.expand_path(directory)
      @config_path = File.join(@directory, CONFIG_FILENAME)
    end

    def exists?
      File.exist?(@config_path)
    end

    def load
      return default_config unless exists?

      begin
        YAML.load_file(@config_path)
      rescue StandardError => e
        puts "Error loading #{CONFIG_FILENAME}: #{e.message}".colorize(:red)
        default_config
      end
    end

    def save(config)
      FileUtils.mkdir_p(File.dirname(@config_path))
      File.write(@config_path, config.to_yaml)
      puts "Created #{CONFIG_FILENAME}".colorize(:green)
    end

    def create_for_type(holocron_type, options = {})
      config = base_config_for_type(holocron_type)

      # Apply any custom options
      config.merge!(options) if options.any?

      save(config)
      config
    end

    def validate(config)
      errors = []

      # Validate required fields
      required_fields = %w[base_repo base_version holocron_type]
      required_fields.each do |field|
        errors << "Missing required field: #{field}" unless config.key?(field)
      end

      # Validate holocron_type
      if config['holocron_type'] && !VALID_HOLOCRON_TYPES.include?(config['holocron_type'])
        errors << "Invalid holocron_type: #{config['holocron_type']}. Must be one of: #{VALID_HOLOCRON_TYPES.join(', ')}"
      end

      # Validate contribute_mode
      if config['contribute_mode'] && !VALID_CONTRIBUTE_MODES.include?(config['contribute_mode'])
        errors << "Invalid contribute_mode: #{config['contribute_mode']}. Must be one of: #{VALID_CONTRIBUTE_MODES.join(', ')}"
      end

      # Validate hierarchy for project-level holocrons
      if (config['holocron_type'] == 'project') && !(config['parent_holocron'] || config['app_holocron'])
        errors << 'Project-level holocrons must specify either parent_holocron or app_holocron'
      end

      errors
    end

    def find_holocron_directory(start_dir = '.')
      current_dir = File.expand_path(start_dir)

      loop do
        config_path = File.join(current_dir, CONFIG_FILENAME)
        return current_dir if File.exist?(config_path)

        parent_dir = File.dirname(current_dir)
        return nil if parent_dir == current_dir # Reached root

        current_dir = parent_dir
      end
    end

    def get_hierarchy_info
      return nil unless exists?

      config = load
      {
        type: config['holocron_type'],
        base_version: config['base_version'],
        base_repo: config['base_repo'],
        parent: config['parent_holocron'],
        app: config['app_holocron'],
        contribute_mode: config['contribute_mode']
      }
    end

    private

    def default_config
      {
        'base_repo' => 'https://github.com/dandailey/holocron',
        'base_version' => Holocron::VERSION,
        'base_commit' => nil,
        'local_base_path' => nil,
        'contribute_mode' => 'local',
        'holocron_type' => 'app',
        'parent_holocron' => nil,
        'app_holocron' => nil,
        'auto_upgrade' => false,
        'upgrade_notifications' => true
      }
    end

    def base_config_for_type(holocron_type)
      case holocron_type
      when 'base'
        {
          'base_repo' => 'https://github.com/dandailey/holocron',
          'base_version' => Holocron::VERSION,
          'base_commit' => nil,
          'local_base_path' => nil,
          'contribute_mode' => 'disabled',
          'holocron_type' => 'base',
          'parent_holocron' => nil,
          'app_holocron' => nil,
          'auto_upgrade' => false,
          'upgrade_notifications' => false
        }
      when 'app'
        {
          'base_repo' => 'https://github.com/dandailey/holocron',
          'base_version' => Holocron::VERSION,
          'base_commit' => nil,
          'local_base_path' => nil,
          'contribute_mode' => 'local',
          'holocron_type' => 'app',
          'parent_holocron' => nil,
          'app_holocron' => nil,
          'auto_upgrade' => false,
          'upgrade_notifications' => true
        }
      when 'project'
        {
          'base_repo' => 'https://github.com/dandailey/holocron',
          'base_version' => Holocron::VERSION,
          'base_commit' => nil,
          'local_base_path' => nil,
          'contribute_mode' => 'local',
          'holocron_type' => 'project',
          'parent_holocron' => nil,
          'app_holocron' => nil,
          'auto_upgrade' => false,
          'upgrade_notifications' => true
        }
      else
        raise ArgumentError, "Invalid holocron_type: #{holocron_type}"
      end
    end
  end
end
