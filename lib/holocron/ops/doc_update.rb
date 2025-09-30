# frozen_string_literal: true

require 'digest'
require 'fileutils'
require_relative 'base_operation'

module Holocron
  module Ops
    class DocUpdate < BaseOperation
      def call(data)
        name = data['name']
        content = data['content']
        author = data['author']
        message = data['message']

        return error_response('Name parameter required', 400) unless name
        return error_response('Content parameter required', 400) unless content

        return error_response("Document '#{name}' not found", 404) unless ALLOWED_SYSTEM_DOCS.include?(name)

        # Map document names to actual file paths
        file_path = resolve_doc_path(name)
        return error_response("Document '#{name}' not found", 404) unless file_path

        # Check if file exists before writing
        created = !File.exist?(file_path)

        # Ensure parent directory exists
        FileUtils.mkdir_p(File.dirname(file_path))

        # Write file
        File.write(file_path, content, encoding: 'UTF-8')

        # Calculate new hash
        new_sha256 = Digest::SHA256.hexdigest(content)

        {
          name: name,
          sha256: new_sha256,
          bytes_written: content.bytesize,
          created: created,
          author: author,
          message: message
        }
      end

      private

      def resolve_doc_path(name)
        case name
        when 'vision'
          File.join(@holocron_path, 'vision.md')
        when 'roadmap'
          File.join(@holocron_path, 'roadmap.md')
        when 'project_overview'
          File.join(@holocron_path, 'project_overview.md')
        when 'commands'
          File.join(@holocron_path, 'commands.md')
        when 'action_plan'
          File.join(@holocron_path, 'action_plan.md')
        when 'decision_log'
          File.join(@holocron_path, 'decision_log.md')
        when 'env_setup'
          File.join(@holocron_path, 'env_setup.md')
        when 'progress_log'
          File.join(@holocron_path, 'progress_log.md')
        when 'test_list'
          File.join(@holocron_path, 'test_list.md')
        else
          nil
        end
      end
    end
  end
end
