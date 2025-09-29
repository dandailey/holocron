# frozen_string_literal: true

require 'json'
require 'holocron/operations_handler'
require 'holocron/holocron_finder'

module Holocron
  module Commands
    class Ops < BaseCommand
      def initialize(operation, args, options)
        @operation = operation
        @args = args
        @options = options
        @holocron_path = find_holocron_path
      end

      def call
        unless @operation
          show_available_operations
          return
        end

        unless valid_operation?(@operation)
          puts "Unknown operation: #{@operation}".colorize(:red)
          puts "Run 'holo ops' to see available operations.".colorize(:yellow)
          exit 1
        end

        execute_operation
      end

      private

      def find_holocron_path
        holocron_dir = HolocronFinder.find_holocron_directory('.', @options[:dir])
        unless holocron_dir
          puts 'No Holocron found. Use --dir to specify a directory or run from within a Holocron.'.colorize(:red)
          exit 1
        end
        holocron_dir
      end

      def show_available_operations
        puts "Holocron Operations\n".colorize(:green)
        puts "Usage: holo ops <operation> [options]\n\n"

        operations = [
          { name: 'list_files', desc: 'List files with filtering, sorting, and pagination', method: 'GET' },
          { name: 'read_file', desc: 'Read file content with offset/limit support', method: 'GET' },
          { name: 'put_file', desc: 'Create or update a file', method: 'PUT' },
          { name: 'delete_file', desc: 'Delete a file', method: 'DELETE' },
          { name: 'search', desc: 'Search content across files', method: 'POST' },
          { name: 'move_file', desc: 'Move or rename a file', method: 'POST' },
          { name: 'bundle', desc: 'Bundle multiple files', method: 'POST' },
          { name: 'apply_diff', desc: 'Apply a diff to multiple files', method: 'POST' },
          { name: 'doc_get', desc: 'Get system document content', method: 'GET' },
          { name: 'doc_update', desc: 'Update system document content', method: 'PUT' }
        ]

        operations.each do |op|
          puts "  #{op[:name].ljust(15)} #{op[:desc]} (#{op[:method]})"
        end

        puts "\nOptions:"
        puts '  --json                    Output in JSON format'
        puts '  --from-buffer             Read content from buffer file'
        puts '  --stdin                   Read content from stdin'
        puts '  --dir DIR                 Holocron directory (auto-discovered if not specified)'
        puts "\nFor detailed help on a specific operation, run:"
        puts '  holo ops <operation> --help'
      end

      def valid_operation?(operation)
        %w[list_files read_file put_file delete_file search move_file bundle apply_diff doc_get
           doc_update].include?(operation)
      end

      def execute_operation
        data = build_operation_data
        handler = OperationsHandler.new(@holocron_path)

        # Determine HTTP method based on operation
        method = determine_http_method(@operation)

        result = handler.handle_operation(@operation, method, data)

        if result[:error]
          puts "Error: #{result[:error]}".colorize(:red)
          exit result[:status] || 1
        end

        if @options[:json]
          puts JSON.pretty_generate(result)
        else
          display_human_readable_result(result)
        end
      end

      def build_operation_data
        data = {}

        # Handle content from buffer or stdin
        if @options[:from_buffer]
          buffer_path = File.join(@holocron_path, 'tmp', 'buffer')
          if File.exist?(buffer_path)
            data['content'] = File.read(buffer_path, encoding: 'UTF-8')
          else
            puts "Buffer file not found at #{buffer_path}".colorize(:red)
            exit 1
          end
        elsif @options[:stdin]
          data['content'] = $stdin.read
        end

        # Map CLI options to operation parameters
        # This is where we'll implement the 1:1 mapping from CLI flags to HTTP params
        map_cli_options_to_params(data)

        data
      end

      def map_cli_options_to_params(data)
        # Map common options that apply to multiple operations
        data['dir'] = @options[:dir] if @options[:dir]
        data['path'] = @args[0] if @args[0] && !@args[0].start_with?('--')

        # Operation-specific parameter mapping
        case @operation
        when 'list_files'
          map_list_files_params(data)
        when 'read_file'
          map_read_file_params(data)
        when 'put_file'
          map_put_file_params(data)
        when 'delete_file'
          map_delete_file_params(data)
        when 'search'
          map_search_params(data)
        when 'move_file'
          map_move_file_params(data)
        when 'bundle'
          map_bundle_params(data)
        when 'apply_diff'
          map_apply_diff_params(data)
        when 'doc_get'
          map_doc_get_params(data)
        when 'doc_update'
          map_doc_update_params(data)
        end
      end

      def map_list_files_params(data)
        # Handle repeated flags for arrays (e.g., --include-glob can be used multiple times)
        data['include_glob'] = extract_repeated_flag('include_glob')
        data['exclude_glob'] = extract_repeated_flag('exclude_glob')
        data['extensions'] = extract_repeated_flag('extensions')

        data['max_depth'] = @options[:max_depth] if @options[:max_depth]
        data['sort'] = @options[:sort] if @options[:sort]
        data['order'] = @options[:order] if @options[:order]
        data['limit'] = @options[:limit] if @options[:limit]
        data['offset'] = @options[:offset] if @options[:offset]
      end

      def map_read_file_params(data)
        data['offset'] = @options[:offset] if @options[:offset]
        data['limit'] = @options[:limit] if @options[:limit]
      end

      def map_put_file_params(data)
        data['if_match_sha256'] = @options[:if_match_sha256] if @options[:if_match_sha256]
        data['encoding'] = @options[:encoding] if @options[:encoding]
      end

      def map_delete_file_params(data)
        data['if_match_sha256'] = @options[:if_match_sha256] if @options[:if_match_sha256]
      end

      def map_search_params(data)
        data['query'] = @options[:pattern] if @options[:pattern]
        data['regex'] = @options[:regex] if @options[:regex]
        data['case'] = @options[:case_sensitive] ? 'sensitive' : 'insensitive'
        data['before'] = @options[:before] if @options[:before]
        data['after'] = @options[:after] if @options[:after]
        data['include_glob'] = extract_repeated_flag('include_glob')
        data['exclude_glob'] = extract_repeated_flag('exclude_glob')
        data['extensions'] = extract_repeated_flag('extensions')
        data['max_depth'] = @options[:max_depth] if @options[:max_depth]
        data['limit'] = @options[:limit] if @options[:limit]
        data['offset'] = @options[:offset] if @options[:offset]
      end

      def map_move_file_params(data)
        data['from'] = data['path'] if data['path']
        data['to'] = @options[:to_path] if @options[:to_path]
        data['overwrite'] = @options[:overwrite] if @options[:overwrite]
      end

      def map_bundle_params(data)
        data['paths'] = extract_repeated_flag('paths')
        data['max_size'] = @options[:max_size] if @options[:max_size]
      end

      def map_apply_diff_params(data)
        data['diff'] = @options[:diff] if @options[:diff]
        data['dry_run'] = @options[:dry_run] if @options[:dry_run]
      end

      def map_doc_get_params(data)
        data['name'] = @args[0] if @args[0] && !@args[0].start_with?('--')
      end

      def map_doc_update_params(data)
        data['name'] = @args[0] if @args[0] && !@args[0].start_with?('--')
        data['author'] = @options[:author] if @options[:author]
        data['message'] = @options[:message] if @options[:message]
      end

      def extract_repeated_flag(flag_name)
        # Extract values from repeated flags using Thor's repeatable option support
        option_key = flag_name.to_sym
        if @options[option_key]
          # Thor handles repeatable options as arrays
          values = Array(@options[option_key])
          values.any? ? values : nil
        else
          nil
        end
      end

      def determine_http_method(operation)
        case operation
        when 'put_file', 'doc_update'
          'PUT'
        when 'delete_file'
          'DELETE'
        when 'search', 'move_file', 'bundle', 'apply_diff'
          'POST'
        else
          'GET'
        end
      end

      def display_human_readable_result(result)
        case @operation
        when 'list_files'
          display_list_files_result(result)
        when 'read_file'
          display_read_file_result(result)
        when 'put_file', 'delete_file', 'move_file'
          display_file_operation_result(result)
        when 'search'
          display_search_result(result)
        when 'bundle'
          display_bundle_result(result)
        when 'apply_diff'
          display_apply_diff_result(result)
        when 'doc_get'
          display_doc_get_result(result)
        when 'doc_update'
          display_doc_update_result(result)
        else
          puts JSON.pretty_generate(result)
        end
      end

      def display_list_files_result(result)
        if result[:files] && result[:files].any?
          puts "Files (#{result[:total]} total):\n"
          result[:files].each do |file|
            puts "  #{file[:path]} (#{file[:size]} bytes, #{file[:mtime]})"
          end
        else
          puts 'No files found.'
        end
      end

      def display_read_file_result(result)
        if result[:content]
          puts result[:content]
        elsif result[:error]
          puts "Error: #{result[:error]}".colorize(:red)
        end
      end

      def display_file_operation_result(result)
        if result[:success]
          puts 'Operation completed successfully.'.colorize(:green)
          puts "SHA256: #{result[:sha256]}" if result[:sha256]
        elsif result[:error]
          puts "Error: #{result[:error]}".colorize(:red)
        end
      end

      def display_search_result(result)
        if result[:results] && result[:results].any?
          puts "Search results (#{result[:total_matches]} total matches in #{result[:total_files]} files):\n"
          result[:results].each do |file_result|
            file_result[:matches].each do |match|
              puts "  #{file_result[:path]}:#{match[:line_number]}: #{match[:line].strip}"
            end
          end
        else
          puts 'No matches found.'
        end
      end

      def display_bundle_result(result)
        if result[:bundle]
          puts 'Bundle created successfully.'.colorize(:green)
          puts "Size: #{result[:size]} bytes"
          puts "Files: #{result[:file_count]}"
        elsif result[:error]
          puts "Error: #{result[:error]}".colorize(:red)
        end
      end

      def display_apply_diff_result(result)
        if result[:success]
          puts 'Diff applied successfully.'.colorize(:green)
          puts "Files modified: #{result[:files_modified]}" if result[:files_modified]
        elsif result[:error]
          puts "Error: #{result[:error]}".colorize(:red)
        end
      end

      def display_doc_get_result(result)
        if result[:content]
          puts result[:content]
        elsif result[:error]
          puts "Error: #{result[:error]}".colorize(:red)
        end
      end

      def display_doc_update_result(result)
        if result[:sha256]
          puts 'Document updated successfully.'.colorize(:green)
          puts "SHA256: #{result[:sha256]}"
          puts "Bytes written: #{result[:bytes_written]}"
          puts "Created: #{result[:created] ? 'Yes' : 'No'}"
        elsif result[:error]
          puts "Error: #{result[:error]}".colorize(:red)
        end
      end
    end
  end
end
