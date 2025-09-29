# frozen_string_literal: true

require_relative 'base_operation'

module Holocron
  module Ops
    class MoveFile < BaseOperation
      def call(data)
        from = data['from']
        to = data['to']
        if_match_sha256 = data['if_match_sha256']
        overwrite = data['overwrite'] || false
        author = data['author']
        message = data['message']

        return error_response('From parameter required', 400) unless from
        return error_response('To parameter required', 400) unless to

        # Validate paths are not system paths
        validation_error = validate_file_path(from)
        return validation_error if validation_error
        validation_error = validate_file_path(to)
        return validation_error if validation_error

        from_path = safe_file_path(from)
        to_path = safe_file_path(to)

        return error_response('Source file not found', 404) unless File.exist?(from_path)
        return error_response('Source is a directory', 400) if File.directory?(from_path)

        return error_response('Destination exists and overwrite is false', 409) if File.exist?(to_path) && !overwrite

        # Check precondition if specified
        if if_match_sha256
          current_sha256 = file_sha256(from_path)
          if current_sha256 != if_match_sha256
            return error_response('Precondition failed: source file has been modified', 412)
          end
        end

        # Ensure destination directory exists
        FileUtils.mkdir_p(File.dirname(to_path))

        # Move file
        File.rename(from_path, to_path)

        # Get hash of moved file
        sha256 = file_sha256(to_path)

        {
          from: from,
          to: to,
          moved: true,
          sha256: sha256
        }
      end
    end
  end
end
