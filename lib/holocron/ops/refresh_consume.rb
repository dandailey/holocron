# frozen_string_literal: true

require 'fileutils'
require_relative 'base_operation'

module Holocron
  module Ops
    class RefreshConsume < BaseOperation
      def call(data)
        id = data['id'] || data['filename']

        return error_response('ID parameter required', 400) unless id

        context_refresh_dir = File.join(@holocron_path, 'context_refresh')
        return error_response('Context refresh directory not found', 404) unless Dir.exist?(context_refresh_dir)

        # Find the file by ID (filename)
        file_path = File.join(context_refresh_dir, id)
        return error_response('Context refresh not found', 404) unless File.exist?(file_path)

        filename = File.basename(file_path)
        
        # Check if it's already consumed (no _PENDING_ prefix)
        unless filename.start_with?('_PENDING_')
          return error_response('Context refresh already consumed', 400)
        end

        # Remove _PENDING_ prefix
        new_filename = filename.sub('_PENDING_', '')
        new_file_path = File.join(context_refresh_dir, new_filename)

        # Rename the file
        File.rename(file_path, new_file_path)

        # Read the content for response
        content = File.read(new_file_path, encoding: 'UTF-8')
        sha256 = Digest::SHA256.hexdigest(content)

        {
          filename: new_filename,
          original_filename: filename,
          sha256: sha256,
          status: 'consumed',
          consumed_at: Time.now.iso8601
        }
      end
    end
  end
end
