# frozen_string_literal: true

require 'base64'
require_relative 'base_operation'

module Holocron
  module Ops
    class PutFile < BaseOperation
      def call(data)
        path = data['path']
        content = data['content']
        encoding = data['encoding'] || 'plain'
        if_match_sha256 = data['if_match_sha256']
        author = data['author']
        message = data['message']

        return error_response('Path parameter required', 400) unless path
        return error_response('Content parameter required', 400) unless content

        # Validate path is not a system path
        validation_error = validate_file_path(path)
        return validation_error if validation_error

        file_path = safe_file_path(path)

        # Check precondition if specified
        if if_match_sha256
          return error_response('Precondition failed: file does not exist', 412) unless File.exist?(file_path)

          current_sha256 = file_sha256(file_path)
          return error_response('Precondition failed: file has been modified', 412) if current_sha256 != if_match_sha256
        end

        # Decode content if needed
        if encoding == 'base64'
          begin
            content = Base64.decode64(content)
          rescue StandardError => e
            return error_response("Invalid base64 content: #{e.message}", 400)
          end
        end

        # Ensure parent directory exists
        FileUtils.mkdir_p(File.dirname(file_path))

        # Check if file exists before writing
        created = !File.exist?(file_path)

        # Write file
        File.write(file_path, content, encoding: 'UTF-8')

        # Calculate new hash
        new_sha256 = Digest::SHA256.hexdigest(content)

        {
          path: path,
          sha256: new_sha256,
          bytes_written: content.bytesize,
          created: created
        }
      end
    end
  end
end
