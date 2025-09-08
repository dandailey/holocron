# frozen_string_literal: true

require 'holocron/holocron_finder'

module Holocron
  module Commands
    class BaseCommand
      attr_reader :options, :holocron_directory

      def initialize(options = {})
        @options = options
        @holocron_directory = find_holocron_directory
      end

      private

      def find_holocron_directory
        HolocronFinder.find_holocron_directory('.', @options[:dir])
      end

      def require_holocron_directory!
        return if @holocron_directory

        puts '❌ No holocron directory found!'.colorize(:red)
        puts
        puts 'Holocron commands need to be run from within a holocron directory or you can specify one:'.colorize(:yellow)
        puts
        puts '  holo [command] --dir /path/to/holocron'.colorize(:cyan)
        puts '  holo [command] --dir .holocron/sync'.colorize(:cyan)
        puts
        puts 'A valid holocron directory contains:'.colorize(:yellow)
        puts '  • _memory/ directory'.colorize(:white)
        puts
        puts 'Current directory: '.colorize(:yellow) + File.expand_path('.')
        puts
        puts 'To create a new holocron, run:'.colorize(:green)
        puts '  holo init [DIRECTORY]'.colorize(:cyan)
        puts
        exit 1
      end
    end
  end
end
