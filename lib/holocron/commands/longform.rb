# frozen_string_literal: true

require 'fileutils'
require 'colorize'

module Holocron
  module Commands
    class Longform
      def initialize(directory, options)
        @directory = directory
        @options = options
      end

      def concat
        output_file = @options[:output] || "#{File.basename(@directory)}.md"

        puts "Concatenating longform documentation from #{@directory}...".colorize(:blue)

        files = find_numbered_files
        if files.empty?
          puts "❌ No numbered files found in #{@directory}".colorize(:red)
          return
        end

        content = files.map { |file| File.read(file, encoding: 'UTF-8') }.join("\n")
        File.write(output_file, content)

        puts "✅ Created #{output_file} with #{files.length} sections".colorize(:green)
      end

      private

      def find_numbered_files
        Dir.glob(File.join(@directory, '*.md'))
           .select { |file| File.basename(file).match?(/^\d{3}_/) }
           .sort
      end
    end
  end
end
