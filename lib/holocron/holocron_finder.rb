# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'holocron/config_manager'

module Holocron
  class HolocronFinder
    def self.find_holocron_directory(start_dir = '.', explicit_dir = nil)
      # If explicit directory is provided, use it
      if explicit_dir
        explicit_path = File.expand_path(explicit_dir)
        return explicit_path if valid_holocron_directory?(explicit_path)

        puts "❌ Specified directory '#{explicit_dir}' is not a valid holocron directory".colorize(:red)
        puts '   Expected to find either .holocron_base.yml or .holocron.yml or _memory/ directory'.colorize(:yellow)
        return nil
      end

      # Try auto-discovery
      finder = new(start_dir)
      holocron_dir = finder.auto_discover

      unless holocron_dir
        finder.show_discovery_help
        return nil
      end

      holocron_dir
    end

    def self.valid_holocron_directory?(directory)
      return false unless Dir.exist?(directory)

      # Check for new format
      return true if File.exist?(File.join(directory, '.holocron_base.yml'))

      # Check for old format
      return true if File.exist?(File.join(directory, '.holocron.yml'))

      # Check for _memory directory (indicates holocron structure)
      return true if Dir.exist?(File.join(directory, '_memory'))

      false
    end

    def initialize(start_dir = '.')
      @start_dir = File.expand_path(start_dir)
      @config_manager = ConfigManager.new(@start_dir)
    end

    def auto_discover
      # Try to find using new format first
      holocron_dir = @config_manager.find_holocron_directory(@start_dir)
      return holocron_dir if holocron_dir

      # Check if we're already in a holocron directory
      return @start_dir if self.class.valid_holocron_directory?(@start_dir)

      # Look for old .holocron.yml format
      current_dir = @start_dir
      loop do
        old_config_path = File.join(current_dir, '.holocron.yml')
        return current_dir if File.exist?(old_config_path)

        parent_dir = File.dirname(current_dir)
        break if parent_dir == current_dir # Reached root

        current_dir = parent_dir
      end

      # Check for .holocron/sync directory (symlink case)
      sync_dir = File.join(@start_dir, '.holocron', 'sync')
      return sync_dir if Dir.exist?(sync_dir) && Dir.exist?(File.join(sync_dir, '_memory'))

      nil
    end

    def show_discovery_help
      puts
      puts '❌ No holocron directory found!'.colorize(:red)
      puts
      puts 'Holocron commands need to be run from within a holocron directory or you can specify one:'.colorize(:yellow)
      puts
      puts '  holo --dir /path/to/holocron <command>'.colorize(:cyan)
      puts '  holo --dir .holocron/sync <command>'.colorize(:cyan)
      puts
      puts 'A valid holocron directory contains:'.colorize(:yellow)
      puts '  • .holocron_base.yml (new format) OR .holocron.yml (old format) OR _memory/ directory'.colorize(:white)
      puts
      puts 'Current directory: '.colorize(:yellow) + @start_dir
      puts
      puts 'To create a new holocron, run:'.colorize(:green)
      puts '  holo init [DIRECTORY]'.colorize(:cyan)
      puts
    end
  end
end
