# frozen_string_literal: true

require_relative 'base_operation'

module Holocron
  module Ops
    class ListFiles < BaseOperation
      def call(data)
        dir = sanitize_path(data['dir'] || '.')
        include_globs = Array(data['include_glob'] || ['**/*'])
        exclude_globs = Array(data['exclude_glob'] || [])
        extensions = Array(data['extensions'] || [])
        max_depth = data['max_depth']&.to_i
        sort_by = data['sort'] || 'path'
        order = data['order'] || 'asc'
        limit = data['limit']&.to_i
        offset = data['offset']&.to_i || 0

        base_path = @path_resolver.resolve_path(dir)
        return error_response('Directory not found', 404) unless Dir.exist?(base_path)

        files = []

        include_globs.each do |glob|
          pattern = File.join(base_path, glob)
          Dir.glob(pattern, File::FNM_DOTMATCH).each do |file_path|
            next if File.directory?(file_path)
            next if File.basename(file_path).start_with?('.')

            relative_path = file_path.sub(@holocron_path + '/', '')

            # Apply exclude globs
            excluded = exclude_globs.any? do |exclude_glob|
              File.fnmatch?(exclude_glob, relative_path, File::FNM_PATHNAME)
            end
            next if excluded

            # Apply extension filter
            if extensions.any?
              ext = File.extname(relative_path)[1..-1] # Remove leading dot
              next unless extensions.include?(ext)
            end

            # Apply max depth
            if max_depth
              depth = relative_path.count('/')
              next if depth > max_depth
            end

            stat = File.stat(file_path)
            files << {
              path: relative_path,
              size: stat.size,
              mtime: stat.mtime.strftime('%Y-%m-%dT%H:%M:%S%z'),
              ext: File.extname(relative_path)[1..-1] || ''
            }
          end
        end

        # Sort files
        files.sort_by! do |file|
          case sort_by
          when 'mtime'
            file[:mtime]
          when 'size'
            file[:size]
          else
            file[:path]
          end
        end
        files.reverse! if order == 'desc'

        # Apply pagination
        total = files.length
        files = files[offset..-1] || [] if offset > 0
        files = files[0, limit] if limit

        {
          files: files,
          total: total
        }
      end
    end
  end
end
