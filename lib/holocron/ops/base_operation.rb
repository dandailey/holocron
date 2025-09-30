# frozen_string_literal: true

require 'digest'
require 'fileutils'
require_relative '../path_resolver'

module Holocron
  module Ops
    class BaseOperation
      # Whitelist of allowed system documents
      ALLOWED_SYSTEM_DOCS = %w[
        vision
        roadmap
        project_overview
        commands
        action_plan
        decision_log
        env_setup
        progress_log
        test_list
      ].freeze

      def initialize(holocron_path)
        @holocron_path = File.expand_path(holocron_path)
        @path_resolver = PathResolver.new(holocron_path)
      end

      protected

      def safe_file_path(relative_path)
        # Remove any path traversal attempts and ensure it's within holocron root
        clean_path = relative_path.to_s.gsub(%r{\.\./}, '').gsub(%r{^/+}, '').gsub(%r{^\./}, '')
        @path_resolver.resolve_path(clean_path)
      end

      def sanitize_path(path)
        # Simple sanitization for directory paths
        path.to_s.gsub(%r{\.\./}, '').gsub(%r{^/+}, '')
      end

      def error_response(message, status = 400)
        {
          error: message,
          status: status
        }
      end

      def file_sha256(file_path)
        Digest::SHA256.hexdigest(File.read(file_path, encoding: 'UTF-8'))
      end

      def system_path?(relative_path)
        # Check if path is a system path that should be blocked
        clean_path = relative_path.to_s.gsub(%r{\.\./}, '').gsub(%r{^/+}, '').gsub(%r{^\./}, '')

        # Block system files in root directory
        return true if clean_path.match?(%r{^[^/]+\.md$}) && !clean_path.start_with?('files/')

        # Block system directories
        return true if clean_path.start_with?('_memory/') || clean_path.start_with?('decisions/') ||
                       clean_path.start_with?('progress_logs/') || clean_path.start_with?('context_refresh/') ||
                       clean_path.start_with?('knowledge_base/') || clean_path.start_with?('longform_docs/')

        false
      end

      def validate_file_path(relative_path)
        return error_response('Use resource ops or paths under files/.', 403) if system_path?(relative_path)

        nil
      end
    end
  end
end
