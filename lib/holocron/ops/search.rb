# frozen_string_literal: true

require_relative 'base_operation'
require_relative 'list_files'

module Holocron
  module Ops
    class Search < BaseOperation
      def call(data)
        query = data['query']
        return error_response('Query parameter required', 400) unless query

        regex = data['regex'] || false
        case_sensitive = data['case'] == 'sensitive'
        before = data['before']&.to_i || 0
        after = data['after']&.to_i || 0

        # Get file list using same filtering as list_files
        list_files_op = ListFiles.new(@holocron_path)
        file_data = list_files_op.call(data)
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
            content = File.read(file_path, encoding: 'UTF-8')
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
    end
  end
end
