# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'holocron/path_resolver'
require 'holocron/template_manager'

module Holocron
  module Commands
    class Contribute
      def initialize(options = {})
        @options = options
      end

      def call
        unless in_holocron_project?
          puts '❌ This command must be run from a Holocron project directory'.colorize(:red)
          puts 'Make sure you\'re in a directory with holocron.gemspec and lib/holocron.rb'
          puts 'This command is for contributing to the Holocron project itself.'
          return
        end

        puts '🚀 Initializing contributor working memory...'.colorize(:blue)

        if Dir.exist?('.holocron')
          unless @options[:force]
            puts '⚠️  .holocron directory already exists'.colorize(:yellow)
            puts 'This will overwrite your existing working memory.'
            puts 'Use --force to proceed with overwriting'
            return
          end
          puts '⚠️  Overwriting existing .holocron directory...'.colorize(:yellow)
        end

        create_directory_structure
        create_project_specific_readme
        create_contributor_files
        copy_templates

        puts '✅ Contributor working memory initialized!'.colorize(:green)
        puts 'Next steps:'.colorize(:yellow)
        puts '  - Read .holocron/README.md to understand the project'
        puts '  - Update .holocron/env_setup.md with your environment'
        puts '  - Start tracking your development decisions and progress'
        puts "  - Use 'holo doctor .holocron' to validate your setup"
      end

      private

      def create_directory_structure
        FileUtils.mkdir_p('.holocron')

        %w[
          progress_logs
          context_refresh
          knowledge_base
          longform_docs
          files
        ].each do |dir|
          FileUtils.mkdir_p(File.join('.holocron', dir))
        end
      end

      def create_project_specific_readme
        readme_content = <<~README
          # Holocron Development Working Memory

          This is your personal working memory for contributing to the Holocron project. It follows the standard Holocron structure and is ignored by git to prevent conflicts between contributors.

          ## Project Overview

          **Holocron** is a persistent memory framework for AI assistants working on long-form projects. This repository contains the Ruby gem that provides CLI tools for managing Holocron structures.

          ### Key Information
          - **Repository**: https://github.com/dandailey/holocron
          - **Gem name**: holocron
          - **Ruby version**: 3.1+
          - **Main executable**: `holo`

          ### Project Structure
          - `lib/` - Ruby source code
          - `exe/` - CLI executable
          - `docs/` - Project documentation
          - `spec/` - Test suite
          - `.holocron/` - Your working memory (this directory)

          ## Quick Access
          - **Environment setup**: [\`env_setup.md\`](env_setup.md)
          - **Development decisions**: [\`decision_log.md\`](decision_log.md)
          - **Test tracking**: [\`test_list.md\`](test_list.md)
          - **Project roadmap**: [\`../docs/roadmap.md\`](../docs/roadmap.md)
          - **Contributing guide**: [\`../docs/contributing.md\`](../docs/contributing.md)

          ## Development Workflow

          ### Getting Started
          1. **Environment**: Set up Ruby 3.1+ and run `bundle install`
          2. **Testing**: Run `bundle exec rspec` to ensure tests pass
          3. **CLI testing**: Use `bundle exec exe/holo` to test commands
          4. **Documentation**: Read the docs in `../docs/` for detailed information

          ### Common Commands
          ```bash
          # Test the gem (when developing)
          bundle exec exe/holo version
          bundle exec exe/holo init test-project
          bundle exec exe/holo doctor test-project

          # Run tests
          bundle exec rspec

          # Build gem
          gem build holocron.gemspec

          # Install locally
          gem install ./holocron-0.1.0.gem

          # Once installed, use directly (no bundle exec needed)
          holo version
          holo init test-project
          holo doctor test-project
          ```

          ### Working Memory Usage
          - **Track decisions** in `decision_log.md`
          - **Log progress** in `progress_logs/`
          - **Document environment** in `env_setup.md`
          - **Create context refreshes** with `holo context-refresh --name "reason"`
          - **Submit suggestions** with `holo suggest "idea"`

          ## Project Context

          This is a Ruby gem that provides CLI tools for managing Holocron persistent memory frameworks. The gem is self-contained and works offline, making it easy for AI assistants to maintain context across chat sessions.

          ### Key Features
          - `holo init` - Initialize new Holocron projects
          - `holo doctor` - Validate Holocron structure
          - `holo context-refresh` - Create context refresh files
          - `holo longform concat` - Concatenate documentation
          - `holo suggest` - Submit framework suggestions

          ### Architecture
          - **CLI Framework**: Thor for command-line interface
          - **Templates**: Embedded in gem for self-contained operation
          - **Configuration**: YAML-based configuration files
          - **Modular Design**: Separate command classes for extensibility

          ## Contributing

          See [../docs/contributing.md](../docs/contributing.md) for detailed contribution guidelines.

          ## Resources

          - [Main README](../README.md)
          - [Installation Guide](../docs/installation.md)
          - [Commands Reference](../docs/commands.md)
          - [Architecture](../docs/architecture.md)
          - [Roadmap](../docs/roadmap.md)
          - [Troubleshooting](../docs/troubleshooting.md)

          ---

          *This working memory is personal to you and ignored by git. Use it to track your development decisions, progress, and context as you contribute to the project.*
        README

        File.write(File.join('.holocron', 'README.md'), readme_content)
      end

      def create_contributor_files
        # Create project-specific action plan
        action_plan_content = <<~CONTENT
          # Action Plan - Holocron Development

          ## Current Focus
          - [ ] Review project structure and documentation
          - [ ] Set up development environment
          - [ ] Understand the codebase architecture
          - [ ] Identify areas for contribution

          ## Development Tasks
          - [ ] Write tests for existing functionality
          - [ ] Improve error handling and validation
          - [ ] Add new features from roadmap
          - [ ] Improve documentation
          - [ ] Fix bugs and issues

          ## Learning Tasks
          - [ ] Study the Thor CLI framework
          - [ ] Understand the template system
          - [ ] Learn the testing approach
          - [ ] Review contribution guidelines

          ## Contribution Ideas
          - [ ] Add new CLI commands
          - [ ] Improve user experience
          - [ ] Add integration features
          - [ ] Optimize performance
          - [ ] Enhance documentation
        CONTENT

        File.write(File.join('.holocron', 'action_plan.md'), action_plan_content)

        # Create project-specific project overview
        project_overview_content = <<~CONTENT
          # Project Overview - Holocron Development

          ## What is Holocron?
          Holocron is a Ruby gem that provides CLI tools for managing persistent memory frameworks for AI assistants. It solves the problem of AI assistants having no memory between chat sessions.

          ## Project Goals
          - Provide easy-to-use CLI tools for Holocron management
          - Enable self-contained operation without external dependencies
          - Support cross-platform usage
          - Maintain clean, extensible architecture

          ## Technical Stack
          - **Ruby 3.1+** - Programming language
          - **Thor** - CLI framework
          - **YAML** - Configuration format
          - **RSpec** - Testing framework
          - **RuboCop** - Code style checker

          ## Key Components
          - **CLI Layer** - Command-line interface using Thor
          - **Command Layer** - Individual command implementations
          - **Template System** - Embedded templates for self-contained operation
          - **Configuration** - YAML-based project configuration

          ## Development Environment
          - Ruby 3.1 or higher
          - Bundler for dependency management
          - Git for version control
          - Text editor or IDE of choice

          ## Success Metrics
          - All tests pass
          - CLI commands work reliably
          - Documentation is comprehensive
          - Code follows style guidelines
          - Easy for new contributors to get started
        CONTENT

        File.write(File.join('.holocron', 'project_overview.md'), project_overview_content)
      end

      def copy_templates
        # Copy standard Holocron templates
        TemplateManager.new('.holocron').copy_templates
      end

      def in_holocron_project?
        File.exist?('holocron.gemspec') && File.exist?('lib/holocron.rb')
      end
    end
  end
end
