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
require 'holocron/commands/buffer'
require 'holocron/commands/notebook'
require 'holocron/holocron_finder'

module Holocron
  class CLI < Thor
    # Global options available to all commands
    class_option :dir, type: :string, desc: 'Holocron directory (auto-discovered if not specified)'
    desc 'init [DIRECTORY]', 'Initialize a new Holocron in the specified directory'
    option :into, type: :string, default: 'holocron', desc: 'Directory to create the Holocron in'
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

    desc 'context-refresh', 'Create a new context refresh file'
    option :name, type: :string, desc: 'Custom name for the entry (default: context_refresh)'
    option :from_buffer, type: :boolean, desc: 'Read content from buffer file instead of using template'
    def context_refresh
      Commands::Context.new(options).new_refresh
    end

    desc 'suggest [MESSAGE]', 'Create a suggestion for the base Holocron framework'
    option :open_issue, type: :boolean, default: false, desc: 'Open a GitHub issue'
    option :from_buffer, type: :boolean, desc: 'Read content from buffer file instead of MESSAGE'
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

    desc 'progress [CONTENT]', 'Add a progress log entry'
    option :summary, type: :string, desc: 'Brief summary (auto-generated if not provided)'
    option :name, type: :string, desc: 'Custom name for the entry (default: progress_update)'
    option :from_buffer, type: :boolean, desc: 'Read content from buffer file instead of CONTENT argument'
    def progress(content = nil)
      Commands::Progress.new(content, options).add_entry
    end

    desc 'status [DIRECTORY]', 'Show holocron hierarchy and version information'
    def status(directory = '.')
      Commands::Status.new(directory, options).call
    end

    desc 'buffer [ACTION]', 'Manage buffer file for longform content'
    def buffer(action = nil)
      Commands::Buffer.new(action, options).call
    end

    desc 'notebook [ACTION] [NAME] [FILE_ID] [CONTENT]', 'Manage research notebooks for systematic knowledge extraction'
    option :from_buffer, type: :boolean, desc: 'Read content from buffer file instead of CONTENT argument'
    option :name, type: :string, desc: 'Notebook name (for new command)'
    def notebook(action = nil, name = nil, file_id = nil, content = nil)
      # Handle --name option for new command
      name = options[:name] if options[:name]

      # Handle --from-buffer for content
      content = '--from-buffer' if options[:from_buffer] && content.nil?

      Commands::Notebook.new(action, name, file_id, content, options).call
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
