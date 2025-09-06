# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'holocron/config_manager'
require 'holocron/framework_manager'

module Holocron
  module Commands
    class Upgrade < BaseCommand
      def initialize(directory, options)
        super(options)
        @directory = File.expand_path(directory)
        @config_manager = ConfigManager.new(@directory)
      end

      def call
        # Use --dir option if provided, otherwise use the directory parameter
        search_dir = @options[:dir] ? File.expand_path(@options[:dir]) : @directory
        holocron_dir = @config_manager.find_holocron_directory(search_dir)

        unless holocron_dir
          puts "No Holocron found in #{search_dir} or parent directories".colorize(:red)
          return
        end

        # Update config_manager to use the found holocron directory
        @config_manager = ConfigManager.new(holocron_dir)

        framework_manager = FrameworkManager.new(holocron_dir)

        unless framework_manager.framework_vendored?
          puts "No vendored framework found. Run 'holo init --type=app' first.".colorize(:yellow)
          return
        end

        return unless framework_manager.upgrade_framework

        puts 'Next steps:'.colorize(:yellow)
        puts '  - Review changes in _framework/ directory'
        puts '  - Update your project files if needed'
        puts "  - Run 'holo doctor' to validate the upgrade"
      end
    end
  end
end
