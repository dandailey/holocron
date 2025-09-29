# frozen_string_literal: true

require_relative 'base_operation'

module Holocron
  module Ops
    class ProgressList < BaseOperation
      def call(data)
        limit = data['limit']&.to_i || 10
        offset = data['offset']&.to_i || 0

        # Validate parameters
        return error_response('Limit must be a positive integer', 400) if limit < 1
        return error_response('Offset must be a non-negative integer', 400) if offset < 0

        progress_logs_dir = File.join(@holocron_path, 'progress_logs')

        # Check if directory exists
        return { entries: [], total: 0, limit: limit, offset: offset } unless Dir.exist?(progress_logs_dir)

        # Get all progress files, sorted by modification time (newest first)
        progress_files = Dir.glob(File.join(progress_logs_dir, '*.md'))
                            .map { |f| [f, File.mtime(f)] }
                            .sort_by { |_, mtime| -mtime.to_f }
                            .map(&:first)

        total = progress_files.length

        # Apply pagination
        paginated_files = progress_files[offset, limit] || []

        # Parse each file to extract metadata
        entries = paginated_files.map do |file_path|
          parse_progress_file(file_path)
        end

        {
          entries: entries,
          total: total,
          limit: limit,
          offset: offset,
          has_more: (offset + limit) < total
        }
      end

      private

      def parse_progress_file(file_path)
        filename = File.basename(file_path)
        stat = File.stat(file_path)
        content = File.read(file_path, encoding: 'UTF-8')

        # Extract summary from the first line (after # )
        summary = extract_summary(content)

        # Extract timestamp from filename
        timestamp = extract_timestamp_from_filename(filename)

        {
          filename: filename,
          summary: summary,
          timestamp: timestamp,
          size: stat.size,
          mtime: stat.mtime.iso8601,
          sha256: file_sha256(file_path)
        }
      end

      def extract_summary(content)
        # Look for the first # heading
        first_line = content.lines.first&.strip
        return first_line.sub(/^#\s*/, '') if first_line&.start_with?('#')

        # Fallback to first line without #
        first_line || 'Progress update'
      end

      def extract_timestamp_from_filename(filename)
        # Extract timestamp from filename like "2025-09-29_153158_phase_1_complete.md"
        match = filename.match(/^(\d{4}-\d{2}-\d{2}_\d{6})_/)
        return match[1] if match

        # Fallback to file modification time
        File.stat(File.join(@holocron_path, 'progress_logs', filename)).mtime.strftime('%Y-%m-%d_%H%M%S')
      end
    end
  end
end
