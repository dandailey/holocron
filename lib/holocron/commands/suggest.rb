# frozen_string_literal: true

require 'fileutils'
require 'colorize'

module Holocron
  module Commands
    class Suggest < BaseCommand
      def initialize(message, options)
        super(options)
        @message = message
      end

      def call
        if @message.nil?
          puts 'Please provide a suggestion message:'.colorize(:yellow)
          puts "  holo suggest 'Add support for custom templates'"
          return
        end

        require_holocron_directory!
        create_suggestion_file
        puts '✅ Suggestion recorded locally'.colorize(:green)

        return unless @options[:open_issue]

        puts 'Opening GitHub issue...'.colorize(:blue)
        # TODO: Implement GitHub issue creation
        puts 'GitHub integration not yet implemented'.colorize(:yellow)
      end

      private

      def create_suggestion_file
        timestamp = Time.now.strftime('%Y_%m_%d_%H%M%S')
        filename = "#{timestamp}_suggestion.md"
        filepath = File.join(@holocron_directory, '_memory', 'suggestion_queue', filename)

        content = <<~CONTENT
          # Suggestion: #{@message}

          **Date:** #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
          **Status:** Pending

          ## Description
          #{@message}

          ## Rationale
          <!-- Why is this suggestion valuable? -->

          ## Implementation Notes
          <!-- Any thoughts on how this could be implemented? -->
        CONTENT

        FileUtils.mkdir_p(File.dirname(filepath))
        File.write(filepath, content)
      end
    end
  end
end
