# frozen_string_literal: true

require 'fileutils'
require_relative 'base_operation'

module Holocron
  module Ops
    class RefreshCreate < BaseOperation
      def call(data)
        name = data['name'] || 'context_refresh'
        content = data['content']

        return error_response('Content parameter required', 400) unless content

        # Generate timestamp and filename
        timestamp = Time.now.strftime('%Y_%m_%d_%H%M%S')
        slug = generate_slug_from_name(name)
        filename = "_PENDING_#{timestamp}_#{slug}.md"

        # Ensure context_refresh directory exists
        context_refresh_dir = File.join(@holocron_path, 'context_refresh')
        FileUtils.mkdir_p(context_refresh_dir)

        # Create the context refresh file
        file_path = File.join(context_refresh_dir, filename)
        File.write(file_path, content, encoding: 'UTF-8')

        # Calculate hash
        sha256 = Digest::SHA256.hexdigest(content)

        {
          filename: filename,
          sha256: sha256,
          bytes_written: content.bytesize,
          name: name,
          timestamp: timestamp,
          status: 'pending'
        }
      end

      private

      def generate_slug_from_name(name)
        # Convert name to a filename-safe slug while preserving underscores
        name.downcase
            .gsub(/[^a-z0-9\s_-]/, '')  # Keep underscores and hyphens
            .gsub(/\s+/, '_')           # Convert spaces to underscores
            .gsub(/-+/, '_')            # Convert hyphens to underscores
            .gsub(/_+/, '_')            # Collapse multiple underscores
            .gsub(/^_|_$/, '')          # Remove leading/trailing underscores
      end
    end
  end
end
