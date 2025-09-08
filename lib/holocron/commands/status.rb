# frozen_string_literal: true

require 'colorize'

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
        puts '📚 Framework: External reference'.colorize(:yellow)
      end
    end
  end
end
