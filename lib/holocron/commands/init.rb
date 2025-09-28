# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'json'
require 'holocron/template_manager'
require 'holocron/registry'

module Holocron
  module Commands
    class Init
      def initialize(name, directory, options)
        @name = name
        @directory = directory || options[:into]
        @options = options
      end

      def call
        puts "Initializing Holocron '#{@name}' in #{@directory}...".colorize(:blue)

        create_directory_structure
        create_buffer_file
        create_holocron_json
        copy_templates

        register_holocron

        puts '✅ Holocron initialized successfully!'.colorize(:green)
        puts 'Next steps:'.colorize(:yellow)
        puts '  - Read the README.md to understand the framework'
        puts '  - Customize the files for your project'
        puts "  - Run 'holo select #{@name}' to select it"
        puts "  - Run 'holo doctor' to validate your setup"
        puts "  - Run 'holo status' to see holocron information"
      end

      private

      def create_directory_structure
        base_path = File.join(@directory)
        FileUtils.mkdir_p(base_path)

        # Create 0.2 layout by default
        %w[
          progress_logs
          context_refresh
          knowledge_base
          notebooks
          tmp
          longform_docs
          files
        ].each do |dir|
          FileUtils.mkdir_p(File.join(base_path, dir))
        end
      end

      def create_buffer_file
        buffer_path = File.join(@directory, 'tmp', 'buffer')
        File.write(buffer_path, '')
      end

      def create_holocron_json
        holocron_json_path = File.join(@directory, 'HOLOCRON.json')
        holocron_data = {
          version: '0.2.0'
        }
        File.write(holocron_json_path, JSON.pretty_generate(holocron_data))
      end

      def copy_templates
        TemplateManager.new(@directory).copy_templates
      end

      def register_holocron
        registry = Holocron::Registry.load
        registry.add(name: @name, path: File.expand_path(@directory))
        registry.set_default(@name) unless registry.default
        registry.save
      end
    end
  end
end
