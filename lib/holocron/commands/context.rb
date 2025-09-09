# frozen_string_literal: true

require 'fileutils'
require 'colorize'

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
        filename = "#{timestamp}_#{@slug}.md"

        filepath = File.join(@holocron_directory, '_memory', 'context_refresh', filename)

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

        FileUtils.mkdir_p(File.dirname(filepath))
        File.write(filepath, content)

        puts "✅ Created context refresh file: #{filepath}".colorize(:green)
        puts 'Edit the file to add details'.colorize(:yellow)
      end

      private

      def generate_slug_from_name(name)
        # Convert name to a URL-friendly slug
        name.downcase
            .gsub(/[^a-z0-9\s-]/, '')
            .gsub(/\s+/, '_')
            .gsub(/-+/, '_')
            .gsub(/_+/, '_')
            .gsub(/^_|_$/, '')
      end
    end
  end
end
