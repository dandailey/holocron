# frozen_string_literal: true

require_relative 'base_operation'
require_relative 'list_files'

module Holocron
  module Ops
    class BundleFiles < BaseOperation
      def call(data)
        max_total_bytes = data['max_total_bytes']&.to_i || 1_000_000

        # Get files either from explicit paths or filters
        if data['paths']
          file_paths = Array(data['paths'])
          files_info = file_paths.map do |path|
            file_path = safe_file_path(path)
            next unless File.exist?(file_path) && !File.directory?(file_path)

            stat = File.stat(file_path)
            {
              path: path,
              size: stat.size,
              mtime: stat.mtime.iso8601,
              ext: File.extname(path)[1..-1] || ''
            }
          end.compact
        else
          list_files_op = ListFiles.new(@holocron_path)
          file_data = list_files_op.call(data)
          files_info = file_data[:files]
        end

        bundle = {}
        total_bytes = 0
        truncated = false

        files_info.each do |file_info|
          break if truncated

          file_path = safe_file_path(file_info[:path])
          next unless File.exist?(file_path)

          if total_bytes + file_info[:size] > max_total_bytes
            truncated = true
            break
          end

          begin
            content = File.read(file_path, encoding: 'UTF-8')
            bundle[file_info[:path]] = content
            total_bytes += content.bytesize
          rescue StandardError => e
            # Skip files that can't be read
            next
          end
        end

        {
          files: bundle,
          truncated: truncated,
          bytes: total_bytes
        }
      end
    end
  end
end
