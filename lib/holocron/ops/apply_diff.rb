# frozen_string_literal: true

require_relative 'base_operation'
require_relative '../diff_parser'

module Holocron
  module Ops
    class ApplyDiff < BaseOperation
      def call(data)
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
    end
  end
end
