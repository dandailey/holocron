# frozen_string_literal: true

require 'json'
require 'digest'
require 'fileutils'
require_relative 'diff_parser'
require_relative 'path_resolver'

module Holocron
  class OperationsHandler
    def initialize(holocron_path)
      @holocron_path = File.expand_path(holocron_path)
      @path_resolver = PathResolver.new(holocron_path)
    end

    def handle_operation(operation, method, params = {}, body = {})
      # Merge params and body for convenience
      data = params.merge(body)

      case operation
      when 'list_files'
        list_files(data)
      when 'read_file'
        read_file(data)
      when 'put_file'
        return error_response('PUT method required', 405) unless method == 'PUT'

        put_file(data)
      when 'delete_file'
        return error_response('DELETE method required', 405) unless method == 'DELETE'

        delete_file(data)
      when 'search'
        return error_response('POST method required', 405) unless method == 'POST'

        search(data)
      when 'move_file'
        return error_response('POST method required', 405) unless method == 'POST'

        move_file(data)
      when 'bundle'
        return error_response('POST method required', 405) unless method == 'POST'

        bundle_files(data)
      when 'apply_diff'
        return error_response('POST method required', 405) unless method == 'POST'

        apply_diff(data)
      else
        error_response("Unknown operation: #{operation}", 404)
      end
    rescue StandardError => e
      error_response("Internal error: #{e.message}", 500)
    end

    private

    # Core operations

    def list_files(data)
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
            mtime: stat.mtime.iso8601,
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

    def read_file(data)
      path = data['path']
      return error_response('Path parameter required', 400) unless path

      file_path = safe_file_path(path)
      return error_response('File not found', 404) unless File.exist?(file_path)
      return error_response('Path is a directory', 400) if File.directory?(file_path)

      offset = data['offset']&.to_i
      limit = data['limit']&.to_i

      content = File.read(file_path)

      # Apply line-based offset/limit if specified
      if offset || limit
        lines = content.lines
        start_line = offset || 0
        end_line = limit ? start_line + limit - 1 : -1
        content = lines[start_line..end_line].join
      end

      stat = File.stat(file_path)
      sha256 = Digest::SHA256.hexdigest(File.read(file_path)) # Always hash full file

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

    def put_file(data)
      path = data['path']
      content = data['content']
      encoding = data['encoding'] || 'plain'
      if_match_sha256 = data['if_match_sha256']
      author = data['author']
      message = data['message']

      return error_response('Path parameter required', 400) unless path
      return error_response('Content parameter required', 400) unless content

      file_path = safe_file_path(path)

      # Check precondition if specified
      if if_match_sha256
        return error_response('Precondition failed: file does not exist', 412) unless File.exist?(file_path)

        current_sha256 = Digest::SHA256.hexdigest(File.read(file_path))
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
      File.write(file_path, content)

      # Calculate new hash
      new_sha256 = Digest::SHA256.hexdigest(content)

      {
        path: path,
        sha256: new_sha256,
        bytes_written: content.bytesize,
        created: created
      }
    end

    def delete_file(data)
      path = data['path']
      if_match_sha256 = data['if_match_sha256']
      author = data['author']
      message = data['message']

      return error_response('Path parameter required', 400) unless path

      file_path = safe_file_path(path)
      return error_response('File not found', 404) unless File.exist?(file_path)
      return error_response('Path is a directory', 400) if File.directory?(file_path)

      # Check precondition if specified
      if if_match_sha256
        current_sha256 = Digest::SHA256.hexdigest(File.read(file_path))
        return error_response('Precondition failed: file has been modified', 412) if current_sha256 != if_match_sha256
      end

      # Delete file
      File.delete(file_path)

      {
        path: path,
        deleted: true
      }
    end

    def search(data)
      query = data['query']
      return error_response('Query parameter required', 400) unless query

      regex = data['regex'] || false
      case_sensitive = data['case'] == 'sensitive'
      before = data['before']&.to_i || 0
      after = data['after']&.to_i || 0

      # Get file list using same filtering as list_files
      file_data = list_files(data)
      files_to_search = file_data[:files]

      results = []
      total_matches = 0

      # Prepare search pattern
      if regex
        begin
          flags = case_sensitive ? 0 : Regexp::IGNORECASE
          pattern = Regexp.new(query, flags)
        rescue RegexpError => e
          return error_response("Invalid regex: #{e.message}", 400)
        end
      end

      files_to_search.each do |file_info|
        file_path = safe_file_path(file_info[:path])
        next unless File.exist?(file_path)

        begin
          content = File.read(file_path)
          lines = content.lines
          matches = []

          lines.each_with_index do |line, index|
            line_matches = if regex
                             line.match?(pattern)
                           else
                             case_sensitive ? line.include?(query) : line.downcase.include?(query.downcase)
                           end

            next unless line_matches

            line_number = index + 1
            before_lines = []
            after_lines = []

            # Collect context lines
            if before > 0
              start_idx = [0, index - before].max
              before_lines = lines[start_idx...index].map(&:chomp)
            end

            if after > 0
              end_idx = [lines.length, index + after + 1].min
              after_lines = lines[(index + 1)...end_idx].map(&:chomp)
            end

            matches << {
              line_number: line_number,
              line: line.chomp,
              before: before_lines,
              after: after_lines
            }
            total_matches += 1
          end

          if matches.any?
            results << {
              path: file_info[:path],
              matches: matches
            }
          end
        rescue StandardError => e
          # Skip files that can't be read
          next
        end
      end

      {
        query: query,
        total_files: results.length,
        total_matches: total_matches,
        results: results
      }
    end

    def move_file(data)
      from = data['from']
      to = data['to']
      if_match_sha256 = data['if_match_sha256']
      overwrite = data['overwrite'] || false
      author = data['author']
      message = data['message']

      return error_response('From parameter required', 400) unless from
      return error_response('To parameter required', 400) unless to

      from_path = safe_file_path(from)
      to_path = safe_file_path(to)

      return error_response('Source file not found', 404) unless File.exist?(from_path)
      return error_response('Source is a directory', 400) if File.directory?(from_path)

      return error_response('Destination exists and overwrite is false', 409) if File.exist?(to_path) && !overwrite

      # Check precondition if specified
      if if_match_sha256
        current_sha256 = Digest::SHA256.hexdigest(File.read(from_path))
        if current_sha256 != if_match_sha256
          return error_response('Precondition failed: source file has been modified', 412)
        end
      end

      # Ensure destination directory exists
      FileUtils.mkdir_p(File.dirname(to_path))

      # Move file
      File.rename(from_path, to_path)

      # Get hash of moved file
      sha256 = Digest::SHA256.hexdigest(File.read(to_path))

      {
        from: from,
        to: to,
        moved: true,
        sha256: sha256
      }
    end

    def bundle_files(data)
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
        file_data = list_files(data)
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
          content = File.read(file_path)
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

    def apply_diff(data)
      diff_content = data['diff']
      return error_response('Diff parameter required', 400) unless diff_content

      author = data['author']
      message = data['message']

      begin
        # Parse the diff
        parser = DiffParser.new(@holocron_path)
        changes = parser.parse(diff_content)

        # Apply the changes
        results = parser.apply_to_files

        # Calculate summary statistics
        total_files = results.length
        created_files = results.count { |r| r[:created] }
        modified_files = results.count { |r| r[:modified] }
        deleted_files = results.count { |r| r[:deleted] }
        total_hunks = results.sum { |r| r[:hunks_applied] || 0 }
        errors = results.flat_map { |r| r[:errors] }

        {
          applied: true,
          summary: {
            total_files: total_files,
            created: created_files,
            modified: modified_files,
            deleted: deleted_files,
            hunks_applied: total_hunks,
            errors: errors.length
          },
          results: results,
          author: author,
          message: message
        }
      rescue DiffParser::PathError => e
        error_response("Path error: #{e.message}", 403)
      rescue DiffParser::ParseError => e
        error_response("Parse error: #{e.message}", 400)
      rescue DiffParser::DiffError => e
        error_response("Diff error: #{e.message}", 400)
      end
    end

    # Utility methods

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
  end
end
