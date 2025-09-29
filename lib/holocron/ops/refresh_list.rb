# frozen_string_literal: true

require 'fileutils'
require_relative 'base_operation'

module Holocron
  module Ops
    class RefreshList < BaseOperation
      def call(data)
        limit = data['limit']&.to_i
        offset = data['offset']&.to_i || 0

        context_refresh_dir = File.join(@holocron_path, 'context_refresh')
        return { refreshes: [], total: 0 } unless Dir.exist?(context_refresh_dir)

        # Get all context refresh files
        all_files = Dir.glob(File.join(context_refresh_dir, '*.md')).sort_by { |f| File.mtime(f) }.reverse

        refreshes = all_files.map do |file_path|
          filename = File.basename(file_path)
          is_pending = filename.start_with?('_PENDING_')
          status = is_pending ? 'pending' : 'consumed'
          
          # Remove _PENDING_ prefix for display
          display_name = is_pending ? filename.sub('_PENDING_', '') : filename
          
          # Extract timestamp from filename (format: _PENDING_YYYY_MM_DD_HHMMSS_slug.md or YYYY_MM_DD_HHMMSS_slug.md)
          timestamp_match = filename.match(/(?:^_PENDING_)?(\d{4}_\d{2}_\d{2}_\d{6})_/)
          timestamp = timestamp_match ? timestamp_match[1] : nil

          {
            filename: filename,
            display_name: display_name,
            status: status,
            timestamp: timestamp,
            created_at: File.mtime(file_path).iso8601,
            size: File.size(file_path)
          }
        end

        # Apply offset and limit
        total = refreshes.length
        refreshes = refreshes[offset..-1] if offset > 0
        refreshes = refreshes[0, limit] if limit && limit > 0

        {
          refreshes: refreshes,
          total: total,
          limit: limit,
          offset: offset
        }
      end
    end
  end
end
