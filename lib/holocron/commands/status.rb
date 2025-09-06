# frozen_string_literal: true

require 'colorize'
require 'holocron/config_manager'
require 'holocron/framework_manager'

module Holocron
  module Commands
    class Status < BaseCommand
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
        display_holocron_status(holocron_dir)
      end

      private

      def display_holocron_status(holocron_dir)
        puts '🔍 Holocron Status'.colorize(:blue)
        puts '=' * 50

        config = @config_manager.load
        hierarchy_info = @config_manager.get_hierarchy_info

        puts "📍 Location: #{holocron_dir}".colorize(:yellow)
        puts "🏷️  Type: #{hierarchy_info[:type].capitalize}".colorize(:green)
        puts "📦 Base Version: #{hierarchy_info[:base_version]}".colorize(:cyan)
        puts "🔗 Base Repository: #{hierarchy_info[:base_repo]}".colorize(:cyan)
        puts "🤝 Contribute Mode: #{hierarchy_info[:contribute_mode]}".colorize(:magenta)

        puts "👆 Parent Holocron: #{hierarchy_info[:parent]}".colorize(:yellow) if hierarchy_info[:parent]

        puts "🏢 App Holocron: #{hierarchy_info[:app]}".colorize(:yellow) if hierarchy_info[:app]

        # Check for framework vendoring
        framework_manager = FrameworkManager.new(holocron_dir)
        if framework_manager.framework_vendored?
          framework_info = framework_manager.get_framework_info
          puts '📚 Framework: Vendored (self-contained)'.colorize(:green)
          puts "   Version: #{framework_info[:version]}".colorize(:cyan)
          puts "   Files: #{framework_info[:files]}".colorize(:cyan)
        else
          puts '📚 Framework: External reference'.colorize(:yellow)
          puts '   Run "holo vendor" to make self-contained'.colorize(:blue)
        end

        # Check for upgrade availability
        check_upgrade_status(config)

        return unless framework_manager.framework_vendored?

        puts "\n💡 Run 'holo upgrade' to update vendored framework".colorize(:blue)
      end

      def check_upgrade_status(config)
        # This is a placeholder for future upgrade checking logic
        # For now, we'll just show that the feature exists
        if config['upgrade_notifications']
          puts '🔔 Upgrade notifications: Enabled'.colorize(:green)
        else
          puts '🔕 Upgrade notifications: Disabled'.colorize(:yellow)
        end
      end
    end
  end
end
