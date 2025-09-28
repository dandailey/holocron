# frozen_string_literal: true

require 'colorize'
require 'holocron/documentation_loader'

module Holocron
  module Commands
    class Guide
      def initialize(guide_name, options = {})
        @guide_name = guide_name
        @options = options
      end

      def call
        case @guide_name
        when 'refreshing-context'
          puts Holocron::DocumentationLoader.refreshing_context_guide.colorize(:blue)
        when 'creating-long-form-docs'
          puts Holocron::DocumentationLoader.creating_long_form_docs_guide.colorize(:blue)
        when 'offboarding'
          puts Holocron::DocumentationLoader.offboarding_guide.colorize(:blue)
        when 'progress-logging'
          puts Holocron::DocumentationLoader.progress_logging_guide.colorize(:blue)
        when 'notebooks'
          puts Holocron::DocumentationLoader.notebooks_guide.colorize(:blue)
        when 'registry'
          puts Holocron::DocumentationLoader.registry_guide.colorize(:blue)
        when 'server'
          puts Holocron::DocumentationLoader.server_guide.colorize(:blue)
        when 'changelog'
          puts Holocron::DocumentationLoader.changelog_guide.colorize(:blue)
        else
          puts 'Available guides:'.colorize(:yellow)
          puts '  - refreshing-context'
          puts '  - creating-long-form-docs'
          puts '  - offboarding'
          puts '  - progress-logging'
          puts '  - notebooks'
          puts '  - registry'
          puts '  - server'
          puts '  - changelog'
          puts ''
          puts 'Usage: holo guide <guide-name>'.colorize(:green)
        end
      end
    end
  end
end
