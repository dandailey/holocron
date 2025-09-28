# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'holocron/path_resolver'

module Holocron
  module Commands
    class Progress < BaseCommand
      def initialize(content, options)
        super(options)
        @content = determine_content(content, options)
        @summary = options[:summary] || generate_summary_from_content
        @name = options[:name] || 'progress_update'
        @slug = generate_slug_from_name(@name)
      end

      def add_entry
        require_holocron_directory!

        timestamp = Time.now.strftime('%Y-%m-%d_%H%M%S')
        filename = "#{timestamp}_#{@slug}.md"

        path_resolver = PathResolver.new(@holocron_directory)
        filepath = path_resolver.resolve_path("progress_logs/#{filename}")

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
          FileUtils.mkdir_p(File.dirname(buffer_path))
          File.write(buffer_path, '')
          puts 'Error: Buffer file was empty, created new one'.colorize(:red)
          puts 'Add content to tmp/buffer first'.colorize(:yellow)
          exit 1
        end

        content = File.read(buffer_path)
        if content.strip.empty?
          puts 'Error: Buffer file is empty'.colorize(:red)
          puts 'Add content to tmp/buffer first'.colorize(:yellow)
          exit 1
        end

        content
      end

      def update_main_progress_log(holocron_dir, timestamp, summary, filename)
        main_log_path = File.join(holocron_dir, 'progress_log.md')

        # Read existing content or create new file
        existing_content = File.exist?(main_log_path) ? File.read(main_log_path) : "# Progress Log (Summary)\n\n"

        # Add new entry to the summary - keep it concise
        new_entry = <<~ENTRY
          ## #{timestamp}: #{summary}

          *Detailed log: [progress_logs/#{filename}](progress_logs/#{filename})*
        ENTRY

        # Append to the end, before the "See progress_logs/" line if it exists
        updated_content = if existing_content.include?('See `progress_logs/`')
                            existing_content.gsub(
                              'See `progress_logs/` for detailed entries.',
                              "#{new_entry}\n\nSee `progress_logs/` for detailed entries."
                            )
                          else
                            "#{existing_content.chomp}\n#{new_entry}\n\nSee `progress_logs/` for detailed entries.\n"
                          end

        File.write(main_log_path, updated_content)
      end

      def generate_summary_from_content
        # Generate a simple summary from the first line or first 50 characters
        first_line = @content.lines.first&.strip
        if first_line && first_line.length <= 100
          first_line
        else
          @content[0..97] + '...'
        end
      end

      def generate_slug_from_name(name)
        # Convert name to a URL-friendly slug
        name.downcase
            .gsub(/[^a-z0-9\s_-]/, '')
            .gsub(/\s+/, '_')
            .gsub(/-+/, '_')
            .gsub(/_+/, '_')
            .gsub(/^_|_$/, '')
      end
    end
  end
end
