# frozen_string_literal: true

require 'thor'
require 'holocron/commands/base_command'
require 'holocron/commands/init'
require 'holocron/commands/doctor'
require 'holocron/commands/version'
require 'holocron/commands/longform'
require 'holocron/commands/context'
require 'holocron/commands/suggest'
require 'holocron/commands/contribute'
require 'holocron/commands/framework'
require 'holocron/commands/guide'
require 'holocron/commands/onboard'
require 'holocron/commands/progress'
require 'holocron/commands/status'
require 'holocron/commands/upgrade'
require 'holocron/commands/vendor'
require 'holocron/holocron_finder'

module Holocron
  class CLI < Thor
    # Global options available to all commands
    class_option :dir, type: :string, desc: 'Holocron directory (auto-discovered if not specified)'
    desc 'init [DIRECTORY]', 'Initialize a new Holocron in the specified directory'
    option :into, type: :string, default: 'holocron', desc: 'Directory to create the Holocron in'
    option :type, type: :string, default: 'app', desc: 'Type of holocron to create (base|app|project)'
    option :parent, type: :string, desc: 'Path to parent holocron (for project-level holocrons)'
    option :app, type: :string, desc: 'Path to app-level holocron (for project-level holocrons)'
    option :contribute_mode, type: :string, default: 'local',
                             desc: 'Contribution mode (local|github_issue|github_pr|disabled)'
    option :vendor, type: :boolean, default: false, desc: 'Vendor framework files for self-containment'
    def init(directory = nil)
      Commands::Init.new(directory, options).call
    end

    desc 'doctor [DIRECTORY]', 'Validate Holocron structure and report issues'
    option :fix, type: :boolean, default: false, desc: 'Attempt to fix common issues'
    def doctor(directory = '.')
      Commands::Doctor.new(directory, options).call
    end

    desc 'version', 'Show Holocron version'
    def version
      Commands::Version.new.call
    end

    desc 'longform concat DIRECTORY', 'Concatenate longform documentation files'
    option :output, type: :string, desc: 'Output file path'
    def longform_concat(directory)
      Commands::Longform.new(directory, options).concat
    end

    desc 'context-new [REASON]', 'Create a new context refresh file'
    option :why, type: :string, desc: 'Reason for context refresh'
    option :slug, type: :string, desc: 'Custom filename slug (default: context_refresh)'
    option :name, type: :string, desc: 'Alias for --slug'
    option :content, type: :string, desc: 'Full detailed content (if not provided, creates template for manual editing)'
    option :full_content, type: :string, desc: 'Alias for --content'
    def context_new(reason = nil)
      Commands::Context.new(reason, options).new_refresh
    end

    desc 'suggest [MESSAGE]', 'Create a suggestion for the base Holocron framework'
    option :open_issue, type: :boolean, default: false, desc: 'Open a GitHub issue'
    def suggest(message = nil)
      Commands::Suggest.new(message, options).call
    end

    desc 'contribute', 'Initialize a working Holocron for contributing to this project'
    option :force, type: :boolean, default: false, desc: 'Force overwrite existing .holocron directory'
    def contribute
      Commands::Contribute.new(options).call
    end

    desc 'framework', 'Display the Holocron framework guide'
    def framework
      Commands::Framework.new.call
    end

    desc 'guide [GUIDE_NAME]', 'Display a specific Holocron guide'
    def guide(guide_name = nil)
      Commands::Guide.new(guide_name, options).call
    end

    desc 'onboard', 'Display framework guide and process pending context refreshes'
    def onboard
      Commands::Onboard.new(options).call
    end

    desc 'progress SUMMARY', 'Add a progress log entry'
    option :slug, type: :string, desc: 'Custom filename slug (default: progress_update)'
    option :name, type: :string, desc: 'Alias for --slug'
    option :content, type: :string, desc: 'Full detailed content (default: uses SUMMARY)'
    option :full_content, type: :string, desc: 'Alias for --content'
    def progress(summary)
      Commands::Progress.new(summary, options).add_entry
    end

    desc 'status [DIRECTORY]', 'Show holocron hierarchy and version information'
    def status(directory = '.')
      Commands::Status.new(directory, options).call
    end

    desc 'upgrade [DIRECTORY]', 'Update vendored framework from base repository'
    option :force, type: :boolean, default: false, desc: 'Force upgrade even if already up to date'
    def upgrade(directory = '.')
      Commands::Upgrade.new(directory, options).call
    end

    desc 'vendor [DIRECTORY]', 'Vendor framework files for self-containment'
    def vendor(directory = '.')
      Commands::Vendor.new(directory, options).call
    end

    def self.exit_on_failure?
      true
    end

    private

    def holocron_directory
      @holocron_directory ||= HolocronFinder.find_holocron_directory('.', options[:dir])
    end
  end
end
