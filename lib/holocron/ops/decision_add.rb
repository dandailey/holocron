# frozen_string_literal: true

require 'digest'
require 'fileutils'
require_relative 'base_operation'

module Holocron
  module Ops
    class DecisionAdd < BaseOperation
      def call(data)
        content = data['content']
        title = data['title']
        author = data['author']
        message = data['message']

        return error_response('Content parameter required', 400) unless content

        # Generate timestamp and filename
        timestamp = Time.now.strftime('%Y-%m-%d_%H%M%S')
        slug = generate_slug(content, title)
        filename = "#{timestamp}_#{slug}.md"

        # Ensure decisions directory exists
        decisions_dir = File.join(@holocron_path, 'decisions')
        FileUtils.mkdir_p(decisions_dir)

        # Create the detailed decision entry file
        entry_file_path = File.join(decisions_dir, filename)
        entry_content = format_decision_entry(content, title, timestamp)
        File.write(entry_file_path, entry_content, encoding: 'UTF-8')

        # Update the main decision_log.md file
        update_decision_log(filename, title || generate_title(content), timestamp)

        # Calculate hash
        sha256 = Digest::SHA256.hexdigest(entry_content)

        {
          filename: filename,
          sha256: sha256,
          bytes_written: entry_content.bytesize,
          title: title || generate_title(content),
          timestamp: timestamp,
          author: author,
          message: message
        }
      end

      private

      def generate_slug(content, title)
        # Use title if available, otherwise use first line of content
        base_text = title || content.lines.first&.strip || 'decision'

        # Convert to slug: lowercase, replace spaces/special chars with hyphens
        base_text.downcase
                 .gsub(/[^a-z0-9\s-]/, '')
                 .gsub(/\s+/, '-')
                 .gsub(/-+/, '-')
                 .gsub(/^-|-$/, '')
                 .slice(0, 50) # Limit length
      end

      def generate_title(content)
        # Extract first line as title
        first_line = content.lines.first&.strip
        return first_line if first_line && first_line.length <= 100

        # If first line is too long, truncate it
        return first_line.slice(0, 97) + '...' if first_line && first_line.length > 100

        'Decision'
      end

      def format_decision_entry(content, title, timestamp)
        header = title ? "# #{title}\n\n**Date:** #{format_timestamp(timestamp)}\n**Title:** #{title}\n\n## Details\n\n" : "# Decision\n\n**Date:** #{format_timestamp(timestamp)}\n\n## Details\n\n"
        header + content
      end

      def format_timestamp(timestamp)
        # Convert YYYY-MM-DD_HHMMSS to readable format
        Time.strptime(timestamp, '%Y-%m-%d_%H%M%S').strftime('%Y-%m-%d %H:%M:%S')
      end

      def update_decision_log(filename, title, timestamp)
        decision_log_path = File.join(@holocron_path, 'decision_log.md')

        # Read existing content
        existing_content = if File.exist?(decision_log_path)
                             File.read(decision_log_path,
                                       encoding: 'UTF-8')
                           else
                             "# Decision Log\n\n"
                           end

        # Add new entry
        new_entry = "## #{format_timestamp(timestamp)} — #{title}\nDecision: #{title}\nRationale: See detailed log for full context.\n\n*Detailed log: [decisions/#{filename}](decisions/#{filename})*\n\n"

        # Append to the end
        existing_content += new_entry

        # Write back
        File.write(decision_log_path, existing_content, encoding: 'UTF-8')
      end
    end
  end
end
