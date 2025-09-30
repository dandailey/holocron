# frozen_string_literal: true

require 'pathname'

module Holocron
  class DocumentationLoader
    def self.framework_guide
      prepend_date_header(load_documentation('framework.md'))
    end

    def self.refreshing_context_guide
      prepend_date_header(load_documentation('guides/refreshing-context.md'))
    end

    def self.creating_long_form_docs_guide
      prepend_date_header(load_documentation('guides/creating-long-form-docs.md'))
    end

    def self.offboarding_guide
      prepend_date_header(load_documentation('guides/offboarding.md'))
    end

    def self.progress_logging_guide
      prepend_date_header(load_documentation('guides/progress-logging.md'))
    end

    def self.notebooks_guide
      prepend_date_header(load_documentation('guides/notebooks.md'))
    end

    def self.registry_guide
      prepend_date_header(load_documentation('guides/registry.md'))
    end

    def self.server_guide
      prepend_date_header(load_documentation('guides/server.md'))
    end

    def self.changelog_guide
      prepend_date_header(load_documentation('guides/changelog.md'))
    end

    private

    def self.load_documentation(relative_path)
      docs_path = File.join(gem_root, 'docs', relative_path)
      File.read(docs_path, encoding: 'UTF-8')
    rescue Errno::ENOENT
      "Documentation file not found: #{relative_path}"
    end

    def self.prepend_date_header(content)
      current_date = Time.now.strftime('%A, %B %d, %Y')

      header = <<~HEADER
        🗓️  **CURRENT DATE: #{current_date}**
        ⚠️  **AI ATTENTION**: Use this date for all timestamped file naming (YYYY-MM-DD format: #{Time.now.strftime('%Y-%m-%d')})

        ---

      HEADER

      # Ensure both strings are UTF-8 encoded before concatenation
      header.force_encoding('UTF-8') + content.force_encoding('UTF-8')
    end

    def self.gem_root
      @gem_root ||= Pathname.new(__FILE__).join('..', '..', '..').realpath.to_s
    end
  end
end
