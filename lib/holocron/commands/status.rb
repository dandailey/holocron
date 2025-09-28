# frozen_string_literal: true

require 'colorize'
require 'holocron/path_resolver'

module Holocron
  module Commands
    class Status < BaseCommand
      def initialize(directory, options)
        super(options)
        @directory = File.expand_path(directory)
      end

      def call
        # Use --dir option if provided, otherwise use the directory parameter
        search_dir = @options[:dir] ? File.expand_path(@options[:dir]) : @directory
        holocron_dir = HolocronFinder.find_holocron_directory(search_dir)

        unless holocron_dir
          puts "No Holocron found in #{search_dir} or parent directories".colorize(:red)
          return
        end

        display_holocron_status(holocron_dir)
      end

      private

      def display_holocron_status(holocron_dir)
        puts '🔍 Holocron Status'.colorize(:blue)
        puts '=' * 50

        puts "📍 Location: #{holocron_dir}".colorize(:yellow)

        # Detect and display version
        path_resolver = PathResolver.new(holocron_dir)
        version = path_resolver.detect_layout_version

        if version
          puts "📋 Version: #{version}".colorize(:green)

          # Show upgrade recommendation for 0.1 layouts
          if version == '0.1'
            puts '⚠️  Upgrade Available'.colorize(:yellow)
            puts '   Run "holo upgrade" for upgrade instructions'.colorize(:white)
          end
        else
          puts '📋 Version: Unknown'.colorize(:red)
          puts '⚠️  Invalid holocron structure'.colorize(:red)
        end

        puts '📚 Framework: External reference'.colorize(:yellow)
      end
    end
  end
end
