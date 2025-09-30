# frozen_string_literal: true

require 'digest'
require 'fileutils'
require_relative 'base_operation'

module Holocron
  module Ops
    class ProgressAdd < BaseOperation
      def call(data)
        content = data['content']
        summary = data['summary']
        author = data['author']
        message = data['message']

        return error_response('Content parameter required', 400) unless content

        # Generate timestamp and filename
        timestamp = Time.now.strftime('%Y-%m-%d_%H%M%S')
        slug = generate_slug(content, summary)
        filename = "#{timestamp}_#{slug}.md"

        # Ensure progress_logs directory exists
        progress_logs_dir = File.join(@holocron_path, 'progress_logs')
        FileUtils.mkdir_p(progress_logs_dir)

        # Create the detailed progress entry file
        entry_file_path = File.join(progress_logs_dir, filename)
        entry_content = format_progress_entry(content, summary, timestamp)
        File.write(entry_file_path, entry_content, encoding: 'UTF-8')

        # Update the main progress_log.md file
        update_progress_log(filename, summary || generate_summary(content), timestamp)

        # Calculate hash
        sha256 = Digest::SHA256.hexdigest(entry_content)

        {
          filename: filename,
          sha256: sha256,
          bytes_written: entry_content.bytesize,
          summary: summary || generate_summary(content),
          timestamp: timestamp,
          author: author,
          message: message
        }
      end

      private

      def generate_slug(content, summary)
        # Use summary if available, otherwise use first line of content
        base_text = summary || content.lines.first&.strip || 'progress_update'

        # Convert to slug: lowercase, replace spaces/special chars with underscores
        base_text.downcase
                 .gsub(/[^a-z0-9\s_-]/, '')
                 .gsub(/\s+/, '_')
                 .gsub(/-+/, '_')
                 .gsub(/_+/, '_')
                 .gsub(/^_|_$/, '')
                 .slice(0, 50) # Limit length
      end

      def generate_summary(content)
        # Extract first line or first sentence as summary
        first_line = content.lines.first&.strip
        return first_line if first_line && first_line.length <= 100

        # If first line is too long, truncate it
        return first_line.slice(0, 97) + '...' if first_line && first_line.length > 100

        'Progress update'
      end

      def format_progress_entry(content, summary, timestamp)
        header = summary ? "# #{summary}\n\n**Date:** #{format_timestamp(timestamp)}\n**Summary:** #{summary}\n\n## Details\n\n" : "# Progress Update\n\n**Date:** #{format_timestamp(timestamp)}\n\n## Details\n\n"
        header + content
      end

      def format_timestamp(timestamp)
        # Convert YYYY-MM-DD_HHMMSS to readable format
        Time.strptime(timestamp, '%Y-%m-%d_%H%M%S').strftime('%Y-%m-%d %H:%M:%S')
      end

      def update_progress_log(filename, summary, timestamp)
        progress_log_path = File.join(@holocron_path, 'progress_log.md')

        # Read existing content
        existing_content = if File.exist?(progress_log_path)
                             File.read(progress_log_path,
                                       encoding: 'UTF-8')
                           else
                             "# Progress Log (Summary)\n\n"
                           end

        # Add new entry
        new_entry = "- #{format_timestamp(timestamp)}: #{summary}\n\n*Detailed log: [progress_logs/#{filename}](progress_logs/#{filename})*\n\n"

        # Append to the end (before any "See progress_logs/" line if it exists)
        if existing_content.include?('See `progress_logs/`')
          # Insert before the "See progress_logs/" line
          existing_content.gsub!(%r{(See `progress_logs/`.*)}, "#{new_entry}\\1")
        else
          # Just append
          existing_content += new_entry
        end

        # Write back
        File.write(progress_log_path, existing_content, encoding: 'UTF-8')
      end
    end
  end
end
