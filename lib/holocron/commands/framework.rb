# frozen_string_literal: true

require 'colorize'
require 'holocron/documentation_loader'

module Holocron
  module Commands
    class Framework
      def initialize(options = {})
        @options = options
      end

      def call
        content = Holocron::DocumentationLoader.framework_guide
        # Brief registry overview injected at top-level for discoverability
        registry_blurb = <<~BLURB
          \n\n---\n\n**Registry Overview (manage multiple holos globally):**\n- `holo list` — List registered holocrons (marks active/default)\n- `holo select <name>` — Select which holocron commands act upon\n- `holo init <name> <dir>` — Create and register a holocron\n- `holo register <name> <dir>` — Register an existing holocron\n- `holo forget <name>` — Remove a holocron from the registry\n\nFor complete details, run: `holo guide registry`.\n\n---\n
        BLURB

        puts (content + registry_blurb).colorize(:blue)
      end
    end
  end
end
