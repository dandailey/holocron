# frozen_string_literal: true

require 'yaml'
require 'colorize'
require 'fileutils'

module Holocron
  module Commands
    class Doctor < BaseCommand
      def initialize(directory, options)
        super(options)
        @directory = File.expand_path(directory)
        @issues = []
      end

      def call
        # Use --dir option if provided, otherwise use the directory parameter
        search_dir = @options[:dir] ? File.expand_path(@options[:dir]) : @directory
        holocron_dir = HolocronFinder.find_holocron_directory(search_dir)

        unless holocron_dir
          puts "No Holocron found in #{search_dir} or parent directories".colorize(:red)
          return
        end

        @directory = holocron_dir
        puts "🔍 Checking Holocron structure in #{@directory}...".colorize(:blue)

        check_directory_structure
        check_required_files
        check_links

        if @issues.empty?
          puts '✅ All checks passed! Your Holocron is healthy.'.colorize(:green)
        else
          puts "❌ Found #{@issues.length} issue(s):".colorize(:red)
          @issues.each { |issue| puts "  - #{issue}".colorize(:yellow) }

          if @options[:fix]
            puts '🔧 Attempting to fix issues...'.colorize(:blue)
            fix_issues
          end
        end
      end

      private

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
          @issues << "Missing directory: #{dir}" unless Dir.exist?(dir_path)
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
          @issues << "Missing file: #{file}" unless File.exist?(file_path)
        end
      end

      def check_links
        # TODO: Check for broken markdown links
        # This would require parsing markdown files and validating internal links
      end

      def fix_issues
        # TODO: Implement auto-fix for common issues
        puts 'Auto-fix not yet implemented'.colorize(:yellow)
      end
    end
  end
end
