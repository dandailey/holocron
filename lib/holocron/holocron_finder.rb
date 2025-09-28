# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'holocron/registry'
require 'holocron/path_resolver'

module Holocron
  class HolocronFinder
    def self.find_holocron_directory(start_dir = '.', explicit_dir = nil)
      # If explicit directory is provided, use it
      if explicit_dir
        explicit_path = File.expand_path(explicit_dir)
        return explicit_path if valid_holocron_directory?(explicit_path)

        puts "❌ Specified directory '#{explicit_dir}' is not a valid holocron directory".colorize(:red)
        puts '   Expected to find HOLOCRON.json (0.2+) or _memory/ directory (0.1)'.colorize(:yellow)
        return nil
      end

      # Try auto-discovery
      finder = new(start_dir)
      holocron_dir = finder.auto_discover

      # Fallback to active selection in registry when auto-discovery fails
      unless holocron_dir
        registry = Holocron::Registry.load
        if (active = registry.active)
          path = active[:path]
          return path if valid_holocron_directory?(path)
        end

        finder.show_discovery_help
        return nil
      end

      holocron_dir
    end

    def self.valid_holocron_directory?(directory)
      PathResolver.valid_holocron_directory?(directory)
    end

    def initialize(start_dir = '.')
      @start_dir = File.expand_path(start_dir)
    end

    def auto_discover
      # Check if we're already in a holocron directory
      return @start_dir if self.class.valid_holocron_directory?(@start_dir)

      # Walk up the directory tree looking for _memory/ directory
      current_dir = @start_dir
      loop do
        return current_dir if self.class.valid_holocron_directory?(current_dir)

        parent_dir = File.dirname(current_dir)
        break if parent_dir == current_dir # Reached root

        current_dir = parent_dir
      end

      # Check for .holocron/sync directory (symlink case)
      sync_dir = File.join(@start_dir, '.holocron', 'sync')
      return sync_dir if Dir.exist?(sync_dir) && self.class.valid_holocron_directory?(sync_dir)

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
      puts '  • HOLOCRON.json (0.2+) or _memory/ directory (0.1)'.colorize(:white)
      puts
      puts 'Current directory: '.colorize(:yellow) + @start_dir
      puts
      puts 'To create a new holocron, run:'.colorize(:green)
      puts '  holo init [DIRECTORY]'.colorize(:cyan)
      puts
    end
  end
end
