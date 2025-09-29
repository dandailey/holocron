# frozen_string_literal: true

require 'json'

module Holocron
  class PathResolver
    def initialize(holocron_path)
      @holocron_path = File.expand_path(holocron_path)
      @layout_version = detect_layout_version
    end

    # Detect the layout version of this holocron
    def detect_layout_version
      holocron_json_path = File.join(@holocron_path, 'HOLOCRON.json')

      if File.exist?(holocron_json_path)
        begin
          data = JSON.parse(File.read(holocron_json_path, encoding: 'UTF-8'))
          version = data['version']
          return version if version && version.start_with?('0.2')
        rescue JSON::ParserError
          # Invalid JSON, fall back to 0.1 detection
        end
      end

      # Fall back to 0.1 layout detection
      return '0.1' if Dir.exist?(File.join(@holocron_path, '_memory'))

      nil
    end

    # Resolve a logical path to a physical path based on layout version
    def resolve_path(logical_path)
      return File.join(@holocron_path, logical_path) if @layout_version.nil?

      case @layout_version
      when /^0\.2/
        resolve_0_2_path(logical_path)
      when /^0\.1/
        resolve_0_1_path(logical_path)
      else
        File.join(@holocron_path, logical_path)
      end
    end

    # Check if a holocron directory is valid
    def self.valid_holocron_directory?(directory)
      return false unless Dir.exist?(directory)

      # Check for 0.2 layout first
      holocron_json_path = File.join(directory, 'HOLOCRON.json')
      if File.exist?(holocron_json_path)
        begin
          data = JSON.parse(File.read(holocron_json_path, encoding: 'UTF-8'))
          return true if data['version'] && data['version'].start_with?('0.2')
        rescue JSON::ParserError
          # Invalid JSON, continue to 0.1 check
        end
      end

      # Fall back to 0.1 layout detection
      Dir.exist?(File.join(directory, '_memory'))
    end

    private

    def resolve_0_2_path(logical_path)
      # In 0.2 layout, most paths are at root level
      # Only special handling for known 0.1 -> 0.2 mappings
      case logical_path
      when 'decision_log.md'
        File.join(@holocron_path, 'decision_log.md')
      when 'env_setup.md'
        File.join(@holocron_path, 'env_setup.md')
      when 'test_list.md'
        File.join(@holocron_path, 'test_list.md')
      when %r{^progress_logs/}
        File.join(@holocron_path, logical_path)
      when %r{^context_refresh/}
        File.join(@holocron_path, logical_path)
      when %r{^knowledge_base/}
        File.join(@holocron_path, logical_path)
      when %r{^notebooks/}
        File.join(@holocron_path, logical_path)
      when %r{^tmp/}
        File.join(@holocron_path, logical_path)
      when %r{^files/}
        File.join(@holocron_path, logical_path)
      when 'files'
        File.join(@holocron_path, 'files')
      else
        # Default to files/ directory for user content
        File.join(@holocron_path, 'files', logical_path)
      end
    end

    def resolve_0_1_path(logical_path)
      # In 0.1 layout, most paths are under _memory/
      case logical_path
      when 'decision_log.md'
        File.join(@holocron_path, '_memory', 'decision_log.md')
      when 'env_setup.md'
        File.join(@holocron_path, '_memory', 'env_setup.md')
      when 'test_list.md'
        File.join(@holocron_path, '_memory', 'test_list.md')
      when %r{^progress_logs/}
        File.join(@holocron_path, '_memory', logical_path)
      when %r{^context_refresh/}
        File.join(@holocron_path, '_memory', logical_path)
      when %r{^knowledge_base/}
        File.join(@holocron_path, '_memory', logical_path)
      when %r{^notebooks/}
        File.join(@holocron_path, '_memory', logical_path)
      when %r{^tmp/}
        File.join(@holocron_path, '_memory', logical_path)
      else
        # Default to root level for other files
        File.join(@holocron_path, logical_path)
      end
    end
  end
end
