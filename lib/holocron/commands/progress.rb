# frozen_string_literal: true

require 'fileutils'
require 'colorize'

module Holocron
  module Commands
    class Progress < BaseCommand
      def initialize(summary, options)
        super(options)
        @summary = summary
        @slug = options[:slug] || options[:name] || 'progress_update'
        @content = options[:content] || options[:full_content] || summary
      end

      def add_entry
        require_holocron_directory!

        timestamp = Time.now.strftime('%Y-%m-%d_%H%M%S')
        filename = "#{timestamp}_#{@slug}.md"

        filepath = File.join(@holocron_directory, '_memory', 'progress_logs', filename)

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
        update_main_progress_log(@holocron_directory, timestamp, @summary, filename)

        puts "✅ Created progress log entry: #{filepath}".colorize(:green)
        puts '📝 Updated main progress log with summary'.colorize(:green)
      end

      private

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
