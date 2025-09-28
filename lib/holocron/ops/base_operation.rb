# frozen_string_literal: true

require 'digest'
require 'fileutils'
require_relative '../path_resolver'

module Holocron
  module Ops
    class BaseOperation
      def initialize(holocron_path)
        @holocron_path = File.expand_path(holocron_path)
        @path_resolver = PathResolver.new(holocron_path)
      end

      protected

      def safe_file_path(relative_path)
        # Remove any path traversal attempts and ensure it's within holocron root
        clean_path = relative_path.to_s.gsub(%r{\.\./}, '').gsub(%r{^/+}, '')
        @path_resolver.resolve_path(clean_path)
      end

      def sanitize_path(path)
        # Similar to safe_file_path but for directories
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
    end
  end
end
