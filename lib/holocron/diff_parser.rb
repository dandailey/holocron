# frozen_string_literal: true

require 'fileutils'

module Holocron
  class DiffParser
    class DiffError < StandardError; end
    class PathError < DiffError; end
    class ParseError < DiffError; end

    def initialize(holocron_root)
      @holocron_root = File.expand_path(holocron_root)
      @changes = []
    end

    def parse(diff_content)
      @changes = []
      current_file = nil
      current_hunk = nil
      line_number = 0

      diff_content.each_line do |line|
        line_number += 1
        line = line.chomp

        case line
        when %r{^--- a/(.+)$}
          current_file_path = parse_file_path(::Regexp.last_match(1))
          current_file = { path: current_file_path, hunks: [] }
          current_hunk = nil
        when %r{^\+\+\+ b/(.+)$}
          # Validate the file path matches the --- line
          target_path = parse_file_path(::Regexp.last_match(1))
          if current_file && current_file[:path] != target_path
            raise ParseError, "File path mismatch at line #{line_number}: #{current_file[:path]} vs #{target_path}"
          end

          current_file ||= { path: target_path, hunks: [] }
        when /^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@/
          raise ParseError, "No file context at line #{line_number}" unless current_file

          old_start = ::Regexp.last_match(1).to_i
          old_count = ::Regexp.last_match(2) ? ::Regexp.last_match(2).to_i : 1
          new_start = ::Regexp.last_match(3).to_i
          new_count = ::Regexp.last_match(4) ? ::Regexp.last_match(4).to_i : 1

          current_hunk = {
            old_start: old_start,
            old_count: old_count,
            new_start: new_start,
            new_count: new_count,
            lines: []
          }
          current_file[:hunks] << current_hunk
        when /^[+-]/
          raise ParseError, "No hunk context at line #{line_number}" unless current_hunk

          current_hunk[:lines] << {
            type: line[0],
            content: line[1..-1] || '',
            line_number: line_number
          }
        when /^ /
          raise ParseError, "No hunk context at line #{line_number}" unless current_hunk

          current_hunk[:lines] << {
            type: ' ',
            content: line[1..-1] || '',
            line_number: line_number
          }
        when /^\\ No newline at end of file/
          # Ignore this line - it's just git metadata
        else
          # Skip empty lines and other metadata
        end
      end

      @changes << current_file if current_file
      @changes
    end

    def apply_to_files
      results = []

      @changes.each do |file_change|
        file_path = file_change[:path]
        full_path = File.join(@holocron_root, file_path)

        # Validate path is within holocron root
        raise PathError, "Path traversal detected: #{file_path}" unless path_safe?(full_path)

        result = apply_file_change(full_path, file_change)
        results << result
      end

      results
    end

    private

    def parse_file_path(path)
      # Remove leading slash if present
      path = path[1..-1] if path.start_with?('/')

      # Normalize path separators
      path = path.gsub('\\', '/')

      # Validate no path traversal
      raise PathError, "Invalid path: #{path}" if path.include?('..') || path.start_with?('/')

      path
    end

    def path_safe?(full_path)
      normalized_path = File.expand_path(full_path)
      normalized_path.start_with?(@holocron_root) && !normalized_path.include?('..')
    end

    def apply_file_change(full_path, file_change)
      result = {
        path: file_change[:path],
        created: false,
        modified: false,
        deleted: false,
        hunks_applied: 0,
        errors: []
      }

      begin
        # Read existing file if it exists
        existing_content = File.exist?(full_path) ? File.read(full_path) : ''
        existing_lines = existing_content.lines.map(&:chomp)

        # Apply each hunk
        file_change[:hunks].each do |hunk|
          apply_hunk(existing_lines, hunk)
          result[:hunks_applied] += 1
        end

        # Determine if this is a create, modify, or delete
        if !File.exist?(full_path)
          result[:created] = true
        elsif existing_lines != File.read(full_path).lines.map(&:chomp)
          result[:modified] = true
        end

        # Write the file
        FileUtils.mkdir_p(File.dirname(full_path))
        File.write(full_path, existing_lines.join("\n") + "\n")
      rescue StandardError => e
        result[:errors] << e.message
      end

      result
    end

    def apply_hunk(lines, hunk)
      # Convert 1-based line numbers to 0-based array indices
      old_start_idx = hunk[:old_start] - 1
      old_end_idx = old_start_idx + hunk[:old_count] - 1
      new_start_idx = hunk[:new_start] - 1

      # Build the new content for this hunk
      new_lines = []
      old_idx = old_start_idx
      new_idx = new_start_idx

      hunk[:lines].each do |line|
        case line[:type]
        when ' '
          # Context line - keep existing content
          new_lines << lines[old_idx] if old_idx < lines.length
          old_idx += 1
          new_idx += 1
        when '-'
          # Deletion - skip this line from old content
          old_idx += 1
        when '+'
          # Addition - add new content
          new_lines << line[:content]
          new_idx += 1
        end
      end

      # Replace the old lines with new lines
      if hunk[:old_count] > 0
        lines[old_start_idx, hunk[:old_count]] = new_lines
      else
        # Insert at the beginning
        lines.insert(old_start_idx, *new_lines)
      end
    end
  end
end
