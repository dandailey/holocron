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
require 'holocron/commands/server'
require 'holocron/commands/registry'
require 'holocron/holocron_finder'

module Holocron
  class CLI < Thor
    # Global options available to all commands
    class_option :dir, type: :string, desc: 'Holocron directory (auto-discovered if not specified)'
    desc 'init NAME DIRECTORY', 'Initialize a new Holocron with the given name and directory'
    option :into, type: :string, default: 'holocron', desc: 'Directory to create the Holocron in'
    def init(name = nil, directory = nil)
      if name.nil? || directory.nil?
        puts 'Usage: holo init <name> <directory>'.colorize(:yellow)
        exit 1
      end

      Commands::Init.new(name, directory, options).call
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

    desc 'guide [GUIDE_NAME]',
         'Display a specific Holocron guide (available: refreshing-context, creating-long-form-docs, offboarding, progress-logging, notebooks)'
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

    desc 'server [ACTION]', 'Start or manage the Holocron web server'
    option :port, type: :numeric, default: 4567, desc: 'Port to run the server on'
    option :host, type: :string, default: 'localhost', desc: 'Host to bind the server to'
    def server(action = 'start')
      if ['--help', 'help'].include?(action)
        puts 'Holocron Server Commands:'
        puts '  holo server start    - Start the web server'
        puts '  holo server stop     - Stop the web server (not implemented)'
        puts '  holo server status   - Show server status (not implemented)'
        puts ''
        puts 'Options:'
        puts '  --port PORT          - Port to run on (default: 4567)'
        puts '  --host HOST          - Host to bind to (default: localhost)'
        puts ''
        puts 'Examples:'
        puts '  holo server start'
        puts '  holo server start --port 3000'
        puts '  holo server start --host 0.0.0.0 --port 8080'
        return
      end

      Commands::Server.new(action, options).call
    end

    desc 'list', 'List registered holocrons'
    def list
      Commands::RegistryCmd.new('list', options).call
    end

    desc 'select NAME', 'Select an active holocron by name'
    def select(name)
      Commands::RegistryCmd.new('select', options.merge(name: name)).call
    end

    desc 'register NAME DIRECTORY', 'Register an existing holocron by name and directory'
    def register(name = nil, directory = nil)
      Commands::RegistryCmd.new('register', options.merge(name: name, directory: directory)).call
    end

    desc 'forget NAME', 'Remove a holocron from the registry'
    def forget(name = nil)
      Commands::RegistryCmd.new('forget', options.merge(name: name)).call
    end

    def self.exit_on_failure?
      true
    end

    private

    def holocron_directory
      @holocron_directory ||= HolocronFinder.find_holocron_directory('.', options[:dir])
    end

    # Override help to group commands by category for better discoverability
    def self.help(shell, subcommand = false)
      shell.say "Holocron CLI — Help\n\n"

      shell.say 'General (no holo required):', :green
      shell.say '  holo help                         Show this help'
      shell.say '  holo version                      Show Holocron version'
      shell.say '  holo framework                    Show framework guide'
      shell.say '  holo guide [GUIDE_NAME]           Show a specific guide'
      shell.say '  holo onboard                      Framework guide + process refreshes'
      shell.say '  holo server [ACTION]              Manage web server (start/status)'
      shell.say "\n"

      shell.say 'Registry (manage holos globally):', :green
      shell.say '  holo list                         List registered holocrons'
      shell.say '  holo select <NAME>                Select an active holocron'
      shell.say '  holo register <NAME> <DIR>        Register an existing holocron'
      shell.say '  holo forget <NAME>                Remove a holocron from registry'
      shell.say '  holo init <NAME> <DIR>            Create and register a new holocron'
      shell.say "\n"

      shell.say 'Holo-specific (act on selected or --dir):', :green
      shell.say '  holo status [DIR]                 Show holocron information'
      shell.say '  holo doctor [DIR]                 Validate holocron structure'
      shell.say '  holo context-refresh              Create context refresh entry'
      shell.say '  holo progress [CONTENT]           Add progress log entry'
      shell.say '  holo longform concat <DIR>        Concatenate longform docs'
      shell.say '  holo buffer [ACTION]              Manage buffer file'
      shell.say '  holo notebook [ARGS]              Manage notebooks'
      shell.say '  holo suggest [MESSAGE]            Create framework suggestion'
    end
  end
end
