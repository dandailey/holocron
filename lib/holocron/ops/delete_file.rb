# frozen_string_literal: true

require_relative 'base_operation'

module Holocron
  module Ops
    class DeleteFile < BaseOperation
      def call(data)
        path = data['path']
        if_match_sha256 = data['if_match_sha256']
        author = data['author']
        message = data['message']

        return error_response('Path parameter required', 400) unless path

        # Validate path is not a system path
        validation_error = validate_file_path(path)
        return validation_error if validation_error

        file_path = safe_file_path(path)
        return error_response('File not found', 404) unless File.exist?(file_path)
        return error_response('Path is a directory', 400) if File.directory?(file_path)

        # Check precondition if specified
        if if_match_sha256
          current_sha256 = file_sha256(file_path)
          return error_response('Precondition failed: file has been modified', 412) if current_sha256 != if_match_sha256
        end

        # Delete file
        File.delete(file_path)

        {
          path: path,
          deleted: true
        }
      end
    end
  end
end
