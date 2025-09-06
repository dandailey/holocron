# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'holocron/template_manager'
require 'holocron/config_manager'
require 'holocron/framework_manager'

module Holocron
  module Commands
    class Init
      def initialize(directory, options)
        @directory = directory || options[:into]
        @options = options
        @holocron_type = options[:type] || 'app'
        @config_manager = ConfigManager.new(@directory)
      end

      def call
        puts "Initializing #{@holocron_type} Holocron in #{@directory}...".colorize(:blue)

        validate_options
        create_directory_structure
        create_config_file
        copy_templates
        vendor_framework if @options[:vendor]

        puts "✅ #{@holocron_type.capitalize} Holocron initialized successfully!".colorize(:green)
        puts 'Next steps:'.colorize(:yellow)
        puts '  - Read the README.md to understand the framework'
        puts '  - Customize the files for your project'
        puts "  - Run 'holo doctor' to validate your setup"
        puts "  - Run 'holo status' to see holocron hierarchy"
        if @options[:vendor]
          puts '  - Framework is vendored in _framework/ directory'
        else
          puts "  - Run 'holo vendor' to make your holocron self-contained"
        end
      end

      private

      def create_directory_structure
        base_path = File.join(@directory)
        FileUtils.mkdir_p(base_path)

        %w[
          _memory/progress_logs
          _memory/context_refresh
          _memory/knowledge_base
          longform_docs
          files
        ].each do |dir|
          FileUtils.mkdir_p(File.join(base_path, dir))
        end
      end

      def validate_options
        # Validate holocron type
        unless ConfigManager::VALID_HOLOCRON_TYPES.include?(@holocron_type)
          raise ArgumentError,
                "Invalid holocron type: #{@holocron_type}. Must be one of: #{ConfigManager::VALID_HOLOCRON_TYPES.join(', ')}"
        end

        # Validate project-level holocron requirements
        if (@holocron_type == 'project') && !(@options[:parent] || @options[:app])
          raise ArgumentError, 'Project-level holocrons must specify either --parent or --app'
        end

        # Validate contribute mode
        if @options[:contribute_mode] && !ConfigManager::VALID_CONTRIBUTE_MODES.include?(@options[:contribute_mode])
          raise ArgumentError,
                "Invalid contribute mode: #{@options[:contribute_mode]}. Must be one of: #{ConfigManager::VALID_CONTRIBUTE_MODES.join(', ')}"
        end
      end

      def create_config_file
        config_options = {
          'contribute_mode' => @options[:contribute_mode]
        }

        # Add hierarchy information for project-level holocrons
        if @holocron_type == 'project'
          config_options['parent_holocron'] = @options[:parent] if @options[:parent]
          config_options['app_holocron'] = @options[:app] if @options[:app]
        end

        @config_manager.create_for_type(@holocron_type, config_options)
      end

      def copy_templates
        TemplateManager.new(@directory).copy_templates
      end

      def vendor_framework
        framework_manager = FrameworkManager.new(@directory)
        framework_manager.vendor_framework
      end
    end
  end
end
