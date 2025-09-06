# frozen_string_literal: true

require 'colorize'
require 'holocron/config_manager'
require 'holocron/framework_manager'

module Holocron
  module Commands
    class Vendor < BaseCommand
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

        if framework_manager.framework_vendored?
          puts "Framework is already vendored in #{holocron_dir}/_framework".colorize(:yellow)
          puts "Run 'holo upgrade' to update the vendored framework".colorize(:blue)
          return
        end

        return unless framework_manager.vendor_framework

        puts 'Next steps:'.colorize(:yellow)
        puts '  - Your holocron is now self-contained'
        puts '  - Framework files are available in _framework/ directory'
        puts '  - Run "holo status" to see framework information'
        puts '  - Run "holo upgrade" to update the framework in the future'
      end
    end
  end
end
