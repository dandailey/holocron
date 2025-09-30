# frozen_string_literal: true

require 'colorize'
require 'holocron/path_resolver'
require 'holocron/ops/progress_add'

module Holocron
  module Commands
    class Progress < BaseCommand
      def initialize(content, options)
        super(options)
        @content = determine_content(content, options)
        @summary = options[:summary]
      end

      def add_entry
        require_holocron_directory!

        # Call the op (THE business logic)
        op = Holocron::Ops::ProgressAdd.new(@holocron_directory)
        result = op.call({
                           'content' => @content,
                           'summary' => @summary
                         })

        # Handle errors
        if result[:error]
          puts "❌ #{result[:error]}".colorize(:red)
          exit 1
        end

        # Format success output
        puts "✅ Created progress log entry: progress_logs/#{result[:filename]}".colorize(:green)
        puts '📝 Updated main progress log with summary'.colorize(:green)
      end

      private

      def determine_content(content, options)
        if options[:from_buffer]
          read_buffer_content
        else
          content || 'No content provided'
        end
      end

      def read_buffer_content
        path_resolver = PathResolver.new(@holocron_directory)
        buffer_path = path_resolver.resolve_path('tmp/buffer')

        unless File.exist?(buffer_path)
          puts '❌ Buffer file not found!'.colorize(:red)
          puts 'Write content to tmp/buffer first, then try again.'.colorize(:yellow)
          exit 1
        end

        content = File.read(buffer_path, encoding: 'UTF-8')
        if content.strip.empty?
          puts '❌ Buffer file is empty!'.colorize(:red)
          puts 'Write content to tmp/buffer first, then try again.'.colorize(:yellow)
          exit 1
        end

        # Ensure content is properly encoded as UTF-8
        content.encode('UTF-8')
      end
    end
  end
end
