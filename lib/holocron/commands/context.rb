# frozen_string_literal: true
# encoding: utf-8

require 'fileutils'
require 'colorize'
require 'holocron/path_resolver'

module Holocron
  module Commands
    class Context < BaseCommand
      def initialize(options)
        super(options)
        @name = options[:name] || 'context_refresh'
        @slug = generate_slug_from_name(@name)
      end

      def new_refresh
        require_holocron_directory!

        timestamp = Time.now.strftime('%Y_%m_%d_%H%M%S')
        filename = "_PENDING_#{timestamp}_#{@slug}.md"

        path_resolver = PathResolver.new(@holocron_directory)
        filepath = path_resolver.resolve_path("context_refresh/#{filename}")

        if options[:from_buffer]
          # Read content from buffer file
          buffer_path = path_resolver.resolve_path('tmp/buffer')

          unless File.exist?(buffer_path)
            puts '❌ Buffer file not found!'.colorize(:red)
            puts 'Write content to tmp/buffer first, then try again.'.colorize(:yellow)
            return
          end

          content = File.read(buffer_path, encoding: 'UTF-8')

          if content.strip.empty?
            puts '❌ Buffer file is empty!'.colorize(:red)
            puts 'Write content to tmp/buffer first, then try again.'.colorize(:yellow)
            return
          end

          # Ensure content is properly encoded as UTF-8
          content = content.encode('UTF-8')
        else
          # Use template for manual editing
          content = <<~CONTENT
            # Context Refresh

            **Date:** #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}

            ## Current Objective
            <!-- What is the single next thing we intend to deliver? Be specific about the immediate goal and why it matters. -->

            ## Major Accomplishments This Session
            <!-- List the significant work completed, features implemented, bugs fixed, etc. Be comprehensive. -->

            ## Key Decisions Made
            <!-- Document important architectural, technical, or approach decisions. Include reasoning and impact. -->

            ## Architecture & Technical Changes
            <!-- Describe any structural changes, new patterns, refactoring, or technical debt addressed. -->

            ## Files Currently in Flight
            <!-- List specific filepaths being worked on, with brief context about what's happening in each. -->

            ## Dependencies & Environment
            <!-- Any new dependencies, version changes, configuration updates, or environment setup changes. -->

            ## Testing & Quality
            <!-- Test status, linting results, any quality improvements made. -->

            ## Blockers & Unknowns
            <!-- Anything that could bite future-you, unresolved questions, or areas needing investigation. -->

            ## Next Immediate Steps
            <!-- What should future-you do first? Be specific and actionable. -->

            ## Future Considerations
            <!-- Things to keep in mind for upcoming work, potential issues, or strategic decisions ahead. -->

            ## Context for Handoff
            <!-- Any additional context that would help future-you understand the current state and momentum. -->
          CONTENT
        end

        FileUtils.mkdir_p(File.dirname(filepath))
        File.write(filepath, content)

        puts "✅ Created context refresh file: #{filepath}".colorize(:green)
        if options[:from_buffer]
          puts 'Context refresh created from buffer content.'.colorize(:green)
        else
          puts 'Edit the file to add details'.colorize(:yellow)
        end
      end

      private

      def generate_slug_from_name(name)
        # Convert name to a filename-safe slug while preserving underscores
        name.downcase
            .gsub(/[^a-z0-9\s_-]/, '')  # Keep underscores and hyphens
            .gsub(/\s+/, '_')           # Convert spaces to underscores
            .gsub(/-+/, '_')            # Convert hyphens to underscores
            .gsub(/_+/, '_')            # Collapse multiple underscores
            .gsub(/^_|_$/, '')          # Remove leading/trailing underscores
      end
    end
  end
end
