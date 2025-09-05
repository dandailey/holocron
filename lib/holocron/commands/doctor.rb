# frozen_string_literal: true

require "yaml"
require "colorize"
require "fileutils"

module Holocron
  module Commands
    class Doctor
      def initialize(directory, options)
        @directory = directory
        @options = options
        @issues = []
      end

      def call
        puts "🔍 Checking Holocron structure in #{@directory}...".colorize(:blue)
        
        check_config_file
        check_directory_structure
        check_required_files
        check_links
        
        if @issues.empty?
          puts "✅ All checks passed! Your Holocron is healthy.".colorize(:green)
        else
          puts "❌ Found #{@issues.length} issue(s):".colorize(:red)
          @issues.each { |issue| puts "  - #{issue}".colorize(:yellow) }
          
          if @options[:fix]
            puts "🔧 Attempting to fix issues...".colorize(:blue)
            fix_issues
          end
        end
      end

      private

      def check_config_file
        config_path = File.join(@directory, ".holocron.yml")
        unless File.exist?(config_path)
          @issues << "Missing .holocron.yml configuration file"
          return
        end

        begin
          YAML.load_file(config_path)
        rescue => e
          @issues << "Invalid .holocron.yml: #{e.message}"
        end
      end

      def check_directory_structure
        required_dirs = %w[
          _memory
          _memory/progress_logs
          _memory/context_refresh
          _memory/knowledge_base
          longform_docs
          files
        ]

        required_dirs.each do |dir|
          dir_path = File.join(@directory, dir)
          unless Dir.exist?(dir_path)
            @issues << "Missing directory: #{dir}"
          end
        end
      end

      def check_required_files
        required_files = %w[
          README.md
          action_plan.md
          project_overview.md
          progress_log.md
          todo.md
          _memory/decision_log.md
          _memory/env_setup.md
          _memory/test_list.md
        ]

        required_files.each do |file|
          file_path = File.join(@directory, file)
          unless File.exist?(file_path)
            @issues << "Missing file: #{file}"
          end
        end
      end

      def check_links
        # TODO: Check for broken markdown links
        # This would require parsing markdown files and validating internal links
      end

      def fix_issues
        # TODO: Implement auto-fix for common issues
        puts "Auto-fix not yet implemented".colorize(:yellow)
      end
    end
  end
end
