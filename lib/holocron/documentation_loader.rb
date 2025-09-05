# frozen_string_literal: true

require 'pathname'

module Holocron
  class DocumentationLoader
    def self.framework_guide
      load_documentation('framework/README.md')
    end

    def self.refreshing_context_guide
      load_documentation('guides/refreshing-context.md')
    end

    def self.creating_long_form_docs_guide
      load_documentation('guides/creating-long-form-docs.md')
    end

    def self.offboarding_guide
      load_documentation('guides/offboarding.md')
    end

    def self.progress_logging_guide
      load_documentation('guides/progress-logging.md')
    end

    private

    def self.load_documentation(relative_path)
      docs_path = File.join(gem_root, 'docs', relative_path)
      File.read(docs_path)
    rescue Errno::ENOENT
      "Documentation file not found: #{relative_path}"
    end

    def self.gem_root
      @gem_root ||= Pathname.new(__FILE__).join('..', '..', '..').realpath.to_s
    end
  end
end
