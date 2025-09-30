# frozen_string_literal: true

require_relative 'base_operation'

module Holocron
  module Ops
    class DocGet < BaseOperation
      def call(data)
        name = data['name']
        return error_response('Name parameter required', 400) unless name

        return error_response("Document '#{name}' not found", 404) unless ALLOWED_SYSTEM_DOCS.include?(name)

        # Map document names to actual file paths
        file_path = resolve_doc_path(name)
        return error_response("Document '#{name}' not found", 404) unless File.exist?(file_path)

        content = File.read(file_path, encoding: 'UTF-8')
        stat = File.stat(file_path)

        {
          name: name,
          content: content,
          size: stat.size,
          mtime: stat.mtime.iso8601,
          sha256: file_sha256(file_path)
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
