# frozen_string_literal: true

require 'colorize'
require 'holocron/path_resolver'
require 'holocron/ops/refresh_create'

module Holocron
  module Commands
    class Context < BaseCommand
      def initialize(options)
        super(options)
        @name = options[:name] || 'context_refresh'
      end

      def new_refresh
        require_holocron_directory!

        # Determine content (buffer or template)
        content = if options[:from_buffer]
                    read_buffer_content
                  else
                    default_template
                  end

        # Call the op (THE business logic)
        op = Holocron::Ops::RefreshCreate.new(@holocron_directory)
        result = op.call({
                           'name' => @name,
                           'content' => content
                         })

        # Handle errors
        if result[:error]
          puts "❌ #{result[:error]}".colorize(:red)
          exit 1
        end

        # Format success output
        puts "✅ Created context refresh file: context_refresh/#{result[:filename]}".colorize(:green)
        if options[:from_buffer]
          puts 'Context refresh created from buffer content.'.colorize(:green)
        else
          puts 'Edit the file to add details'.colorize(:yellow)
        end
      end

      private

      def read_buffer_content
        path_resolver = PathResolver.new(@holocron_directory)
        buffer_path = path_resolver.resolve_path('tmp/buffer')

        unless File.exist?(buffer_path)
          puts '❌ Buffer file not found!'.colorize(:red)
          puts 'Write content to tmp/buffer first, then try again.'.colorize(:yellow)
          exit 1
        end

        content = File.read(buffer_path, encoding: 'UTF-8')
        if content.strip.empty?
          puts '❌ Buffer file is empty!'.colorize(:red)
          puts 'Write content to tmp/buffer first, then try again.'.colorize(:yellow)
          exit 1
        end

        # Ensure content is properly encoded as UTF-8
        content.encode('UTF-8')
      end

      def default_template
        <<~CONTENT
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
    end
  end
end
