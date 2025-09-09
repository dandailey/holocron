# frozen_string_literal: true

require 'fileutils'
require 'colorize'

module Holocron
  module Commands
    class Buffer < BaseCommand
      def initialize(action, options)
        super(options)
        @action = action || 'show' # Default to 'show' if no action provided
        @buffer_path = File.join(@holocron_directory, '_memory', 'tmp', 'buffer')
      end

      def call
        require_holocron_directory!

        case @action
        when 'show'
          show_buffer
        when 'clear'
          clear_buffer
        when 'status'
          show_status
        else
          puts "Unknown buffer action: #{@action}".colorize(:red)
          puts 'Available actions: show, clear, status'.colorize(:yellow)
          exit 1
        end
      end

      private

      def show_buffer
        ensure_buffer_exists

        content = File.read(@buffer_path)
        if content.strip.empty?
          puts 'Buffer file exists but is empty.'.colorize(:yellow)
          return
        end

        puts 'Buffer content:'.colorize(:blue)
        puts '=' * 50
        puts content
        puts '=' * 50
      end

      def clear_buffer
        if File.exist?(@buffer_path)
          File.delete(@buffer_path)
          puts '✅ Buffer cleared'.colorize(:green)
        else
          puts 'Buffer was already empty'.colorize(:yellow)
        end
      end

      def show_status
        ensure_buffer_exists

        content = File.read(@buffer_path)
        size = content.bytesize
        lines = content.lines.count
        modified = File.mtime(@buffer_path).strftime('%Y-%m-%d %H:%M:%S')

        puts 'Buffer status:'.colorize(:blue)
        puts "  File: #{@buffer_path}"
        puts "  Size: #{size} bytes, #{lines} lines"
        puts "  Modified: #{modified}"
        puts "  Empty: #{content.strip.empty? ? 'Yes' : 'No'}"
      end

      def ensure_buffer_exists
        return if File.exist?(@buffer_path)

        FileUtils.mkdir_p(File.dirname(@buffer_path))
        File.write(@buffer_path, '')
        puts 'Created empty buffer file'.colorize(:green)
      end
    end
  end
end
