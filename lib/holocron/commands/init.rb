# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'holocron/template_manager'

module Holocron
  module Commands
    class Init
      def initialize(directory, options)
        @directory = directory || options[:into]
        @options = options
      end

      def call
        puts "Initializing Holocron in #{@directory}...".colorize(:blue)

        create_directory_structure
        create_buffer_file
        copy_templates

        puts '✅ Holocron initialized successfully!'.colorize(:green)
        puts 'Next steps:'.colorize(:yellow)
        puts '  - Read the README.md to understand the framework'
        puts '  - Customize the files for your project'
        puts "  - Run 'holo doctor' to validate your setup"
        puts "  - Run 'holo status' to see holocron information"
      end

      private

      def create_directory_structure
        base_path = File.join(@directory)
        FileUtils.mkdir_p(base_path)

        %w[
          _memory/progress_logs
          _memory/context_refresh
          _memory/knowledge_base
          _memory/notebooks
          _memory/tmp
          longform_docs
          files
        ].each do |dir|
          FileUtils.mkdir_p(File.join(base_path, dir))
        end
      end

      def create_buffer_file
        buffer_path = File.join(@directory, '_memory', 'tmp', 'buffer')
        File.write(buffer_path, '')
      end

      def copy_templates
        TemplateManager.new(@directory).copy_templates
      end
    end
  end
end
