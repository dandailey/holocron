# frozen_string_literal: true

require 'open3'
require 'shellwords'

module Holocron
  class ShellExecutor
    # Whitelist of safe commands
    ALLOWED_COMMANDS = %w[
      grep find ls head tail wc cat sort uniq
    ].freeze

    # Command-specific option whitelists
    ALLOWED_OPTIONS = {
      'grep' => %w[-r -i -n -v -c -l -h -o -E -F -w -x -A -B -C],
      'find' => %w[-name -type -size -mtime -newer -maxdepth -mindepth],
      'ls' => %w[-l -a -h -t -r -S -1],
      'head' => %w[-n],
      'tail' => %w[-n -f],
      'wc' => %w[-l -w -c -m],
      'cat' => [],
      'sort' => %w[-r -n -u -k],
      'uniq' => %w[-c -d -u]
    }.freeze

    def initialize(holocron_path)
      @holocron_path = holocron_path
    end

    def execute(command, args = [], options = {})
      # Validate command
      unless ALLOWED_COMMANDS.include?(command)
        return error_response("Command '#{command}' is not allowed")
      end

      # Build and validate the full command
      cmd_parts = [command]
      
      # Add options
      if options.is_a?(Hash)
        options.each do |key, value|
          option = key.start_with?('-') ? key : "-#{key}"
          next unless ALLOWED_OPTIONS[command]&.include?(option)
          
          cmd_parts << option
          cmd_parts << value.to_s if value && value != true
        end
      end

      # Add arguments
      args.each { |arg| cmd_parts << sanitize_path(arg) }

      # Execute in the holocron directory
      execute_command(cmd_parts)
    end

    private

    def execute_command(cmd_parts)
      # Join command parts safely
      cmd_string = cmd_parts.shelljoin
      
      # Execute with timeout and in the correct directory
      stdout, stderr, status = nil, nil, nil
      
      begin
        Dir.chdir(@holocron_path) do
          stdout, stderr, status = Open3.capture3(cmd_string)
        end
        
        {
          command: cmd_parts.join(' '),
          stdout: stdout,
          stderr: stderr,
          exit_code: status.exitstatus,
          success: status.success?
        }
      rescue => e
        error_response("Execution failed: #{e.message}")
      end
    end

    def sanitize_path(path)
      # Remove dangerous characters and ensure path stays within holocron
      sanitized = path.to_s.gsub(/[;&|`$(){}\[\]\\]/, '')
      
      # Convert to relative path if it's trying to escape
      if sanitized.start_with?('/')
        sanitized = sanitized.sub(/^\/+/, '')
      end
      
      # Remove .. path traversal attempts
      sanitized.gsub(/\.\.\//, '')
    end

    def error_response(message)
      {
        command: '',
        stdout: '',
        stderr: message,
        exit_code: 1,
        success: false,
        error: message
      }
    end
  end
end
