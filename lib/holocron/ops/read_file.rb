# frozen_string_literal: true

require_relative 'base_operation'

module Holocron
  module Ops
    class ReadFile < BaseOperation
      def call(data)
        path = data['path']
        return error_response('Path parameter required', 400) unless path

        file_path = safe_file_path(path)
        return error_response('File not found', 404) unless File.exist?(file_path)
        return error_response('Path is a directory', 400) if File.directory?(file_path)

        offset = data['offset']&.to_i
        limit = data['limit']&.to_i

        content = File.read(file_path, encoding: 'UTF-8')

        # Apply line-based offset/limit if specified
        if offset || limit
          lines = content.lines
          start_line = offset || 0
          end_line = limit ? start_line + limit - 1 : -1
          content = lines[start_line..end_line].join
        end

        stat = File.stat(file_path)
        sha256 = file_sha256(file_path) # Always hash full file

        result = {
          path: path,
          size: stat.size,
          mtime: stat.mtime.iso8601,
          content: content,
          sha256: sha256
        }

        result[:offset] = offset if offset
        result[:limit] = limit if limit

        result
      end
    end
  end
end
