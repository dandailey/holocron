# frozen_string_literal: true

require 'fileutils'
require 'colorize'

module Holocron
  module Commands
    class Progress
      def initialize(summary, options)
        @summary = summary
        @slug = options[:slug] || options[:name] || 'progress_update'
        @content = options[:content] || options[:full_content] || summary
        @options = options
      end

      def add_entry
        timestamp = Time.now.strftime('%Y-%m-%d')
        filename = "#{timestamp}_#{@slug}.md"

        # Try to find the correct Holocron directory
        holocron_dir = find_holocron_directory
        filepath = File.join(holocron_dir, '_memory', 'progress_logs', filename)

        # Create the detailed progress log entry
        detailed_content = <<~CONTENT
          # #{@summary}

          **Date:** #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
          **Summary:** #{@summary}

          ## Details

          #{@content}

          ## Impact
          <!-- What does this work enable or improve? -->

          ## Next Steps
          <!-- What should happen next as a result of this work? -->
        CONTENT

        FileUtils.mkdir_p(File.dirname(filepath))
        File.write(filepath, detailed_content)

        # Update the main progress log
        update_main_progress_log(holocron_dir, timestamp, @summary, filename)

        puts "✅ Created progress log entry: #{filepath}".colorize(:green)
        puts '📝 Updated main progress log with summary'.colorize(:green)
      end

      private

      def find_holocron_directory
        # Look for .holocron directory in current directory or parent directories
        current_dir = Dir.pwd
        while current_dir != File.dirname(current_dir)
          holocron_path = File.join(current_dir, '.holocron')
          return File.join(holocron_path, 'sync') if Dir.exist?(holocron_path)

          current_dir = File.dirname(current_dir)
        end

        # Fallback to current directory if no .holocron found
        '.'
      end

      def update_main_progress_log(holocron_dir, timestamp, summary, filename)
        main_log_path = File.join(holocron_dir, 'progress_log.md')

        # Read existing content or create new file
        existing_content = File.exist?(main_log_path) ? File.read(main_log_path) : "# Progress Log (Summary)\n\n"

        # Add new entry to the summary - make it verbose and detailed
        new_entry = <<~ENTRY
          ## #{timestamp}: #{summary}
          
          #{@content}
          
          *Detailed log: `_memory/progress_logs/#{filename}`*
        ENTRY

        # Append to the end, before the "See _memory/progress_logs/" line if it exists
        updated_content = if existing_content.include?('See `_memory/progress_logs/`')
                            existing_content.gsub(
                              'See `_memory/progress_logs/` for detailed entries.',
                              "#{new_entry}\n\nSee `_memory/progress_logs/` for detailed entries."
                            )
                          else
                            "#{existing_content.chomp}\n#{new_entry}\n\nSee `_memory/progress_logs/` for detailed entries.\n"
                          end

        File.write(main_log_path, updated_content)
      end
    end
  end
end
