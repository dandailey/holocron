# frozen_string_literal: true

require 'fileutils'
require 'colorize'

module Holocron
  module Commands
    class Onboard
      def initialize(options = {})
        @options = options
      end

      def call
        puts '🚀 Holocron Onboarding'.colorize(:cyan)
        puts '=' * 50
        puts

        # Display the framework guide
        display_framework

        puts
        puts '=' * 50
        puts

        # Process any pending context refreshes
        process_pending_refreshes

        puts
        puts "✅ Onboarding complete! You're ready to work.".colorize(:green)
      end

      private

      def display_framework
        puts '📚 Framework Guide:'.colorize(:yellow)
        puts
        framework_content = Holocron::DocumentationLoader.framework_guide
        puts framework_content
      end

      def process_pending_refreshes
        context_refresh_dir = File.join('_memory', 'context_refresh')
        return unless Dir.exist?(context_refresh_dir)

        pending_files = Dir.glob(File.join(context_refresh_dir, '_PENDING_*.md'))

        if pending_files.empty?
          puts '📋 No pending context refreshes found.'.colorize(:green)
          return
        end

        puts '🔄 Processing pending context refreshes:'.colorize(:yellow)
        puts

        pending_files.each do |file_path|
          filename = File.basename(file_path)
          new_filename = filename.sub('_PENDING_', '')
          new_file_path = File.join(File.dirname(file_path), new_filename)

          # Rename the file to mark as executed
          File.rename(file_path, new_file_path)

          puts "✅ Processed: #{filename} → #{new_filename}".colorize(:green)

          # Display the content
          puts
          puts '📄 Context Refresh Content:'.colorize(:cyan)
          puts '-' * 30
          content = File.read(new_file_path)
          puts content
          puts '-' * 30
          puts
        end
      end
    end
  end
end
