# frozen_string_literal: true

require 'thor'
require 'holocron/commands/init'
require 'holocron/commands/doctor'
require 'holocron/commands/version'
require 'holocron/commands/longform'
require 'holocron/commands/context'
require 'holocron/commands/suggest'
require 'holocron/commands/contribute'
require 'holocron/commands/framework'
require 'holocron/commands/guide'

module Holocron
  class CLI < Thor
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

    desc 'context-new [REASON]', 'Create a new context refresh file'
    option :why, type: :string, desc: 'Reason for context refresh'
    def context_new(reason = nil)
      Commands::Context.new(reason, options).new_refresh
    end

    desc 'suggest [MESSAGE]', 'Create a suggestion for the base Holocron framework'
    option :open_issue, type: :boolean, default: false, desc: 'Open a GitHub issue'
    def suggest(message = nil)
      Commands::Suggest.new(message, options).call
    end

    desc 'contribute', 'Initialize a working Holocron for contributing to this project'
    def contribute
      Commands::Contribute.new.call
    end

    desc 'framework', 'Display the Holocron framework guide'
    def framework
      Commands::Framework.new.call
    end

    desc 'guide [GUIDE_NAME]', 'Display a specific Holocron guide'
    def guide(guide_name = nil)
      Commands::Guide.new(guide_name, options).call
    end

    def self.exit_on_failure?
      true
    end
  end
end
