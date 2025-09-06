# frozen_string_literal: true

require 'fileutils'
require 'colorize'

module Holocron
  module Commands
    class Context < BaseCommand
      def initialize(reason, options)
        super(options)
        @reason = reason || options[:why] || 'Manual context refresh'
        @slug = options[:slug] || options[:name]
        @content = options[:content] || options[:full_content]
      end

      def new_refresh
        require_holocron_directory!

        timestamp = Time.now.strftime('%Y_%m_%d_%H%M%S')
        slug = @slug ? @slug.gsub(/[^a-zA-Z0-9_-]/, '_') : 'context_refresh'
        filename = "_PENDING_#{timestamp}_#{slug}.md"

        filepath = File.join(@holocron_directory, '_memory', 'context_refresh', filename)

        if @content
          # Use provided content directly
          content = @content
        else
          # Use template for manual editing
          content = <<~CONTENT
            # Context Refresh - #{@reason}

            **Date:** #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
            **Reason:** #{@reason}

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
        puts 'Edit the file to add details, then rename it to remove _PENDING_ prefix'.colorize(:yellow)
      end

      private
    end
  end
end
