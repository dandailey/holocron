# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'holocron/config_manager'

module Holocron
  class FrameworkManager
    FRAMEWORK_DIR = '_framework'

    def initialize(holocron_directory)
      @holocron_dir = File.expand_path(holocron_directory)
      @framework_dir = File.join(@holocron_dir, FRAMEWORK_DIR)
      @config_manager = ConfigManager.new(@holocron_dir)
    end

    def vendor_framework
      return false unless @config_manager.exists?

      config = @config_manager.load
      base_repo = config['base_repo']
      base_version = config['base_version']

      puts "Vendoring framework v#{base_version} from #{base_repo}...".colorize(:blue)

      begin
        create_framework_structure
        copy_framework_files
        update_framework_version(base_version)

        puts '✅ Framework vendored successfully!'.colorize(:green)
        puts "📁 Framework files available in: #{@framework_dir}".colorize(:cyan)
        true
      rescue StandardError => e
        puts "❌ Failed to vendor framework: #{e.message}".colorize(:red)
        false
      end
    end

    def upgrade_framework
      return false unless @config_manager.exists?

      config = @config_manager.load
      current_version = config['base_version']
      latest_version = get_latest_version(config['base_repo'])

      if current_version == latest_version
        puts "Framework is already up to date (v#{current_version})".colorize(:green)
        return true
      end

      puts "Upgrading framework from v#{current_version} to v#{latest_version}...".colorize(:blue)

      begin
        backup_framework
        copy_framework_files
        update_framework_version(latest_version)

        # Update configuration
        config['base_version'] = latest_version
        config['base_commit'] = get_latest_commit(config['base_repo'])
        @config_manager.save(config)

        puts '✅ Framework upgraded successfully!'.colorize(:green)
        true
      rescue StandardError => e
        puts "❌ Failed to upgrade framework: #{e.message}".colorize(:red)
        restore_framework_backup
        false
      end
    end

    def framework_vendored?
      File.exist?(@framework_dir) && !Dir.empty?(@framework_dir)
    end

    def get_framework_info
      return nil unless framework_vendored?

      version_file = File.join(@framework_dir, 'VERSION')
      version = File.exist?(version_file) ? File.read(version_file).strip : 'unknown'

      {
        path: @framework_dir,
        version: version,
        files: count_framework_files
      }
    end

    private

    def create_framework_structure
      FileUtils.mkdir_p(@framework_dir)

      %w[shared_guides templates].each do |dir|
        FileUtils.mkdir_p(File.join(@framework_dir, dir))
      end
    end

    def copy_framework_files
      # Copy framework documentation
      copy_framework_readme
      copy_shared_guides
      copy_templates
      create_version_file
    end

    def copy_framework_readme
      readme_content = generate_framework_readme
      File.write(File.join(@framework_dir, 'README.md'), readme_content)
    end

    def copy_shared_guides
      # For now, create placeholder shared guides
      # In a real implementation, these would be copied from the base repository
      shared_guides_dir = File.join(@framework_dir, 'shared_guides')

      placeholder_guide = <<~GUIDE
        # Shared Guides

        This directory contains cross-project knowledge and best practices that are shared across all holocrons.

        ## Available Guides

        - **Development Workflow**: Best practices for development processes
        - **Documentation Standards**: Guidelines for writing effective documentation
        - **Testing Strategies**: Approaches to testing in different contexts
        - **Deployment Patterns**: Common deployment and release patterns

        ## Contributing

        To contribute new shared guides:
        1. Create a new markdown file in this directory
        2. Follow the existing naming conventions
        3. Include clear examples and explanations
        4. Update this README to reference your new guide
      GUIDE

      File.write(File.join(shared_guides_dir, 'README.md'), placeholder_guide)
    end

    def copy_templates
      # For now, create placeholder templates
      # In a real implementation, these would be copied from the base repository
      templates_dir = File.join(@framework_dir, 'templates')

      template_readme = <<~TEMPLATE
        # Framework Templates

        This directory contains templates for different types of holocrons and project structures.

        ## Available Templates

        - **Base Holocron**: Template for base holocrons
        - **App Holocron**: Template for application-level holocrons
        - **Project Holocron**: Template for project-level holocrons

        ## Usage

        Templates are automatically applied when creating new holocrons with the appropriate type.
      TEMPLATE

      File.write(File.join(templates_dir, 'README.md'), template_readme)
    end

    def create_version_file
      config = @config_manager.load
      version_content = "#{config['base_version']}\n"
      File.write(File.join(@framework_dir, 'VERSION'), version_content)
    end

    def update_framework_version(version)
      version_file = File.join(@framework_dir, 'VERSION')
      File.write(version_file, "#{version}\n")
    end

    def generate_framework_readme
      config = @config_manager.load

      <<~README
        # Holocron Framework

        This is a vendored copy of the Holocron framework, providing self-contained access to framework documentation and resources.

        ## Framework Information

        - **Version**: #{config['base_version']}
        - **Repository**: #{config['base_repo']}
        - **Holocron Type**: #{config['holocron_type']}

        ## Contents

        - **shared_guides/**: Cross-project knowledge and best practices
        - **templates/**: Framework templates for different holocron types

        ## Usage

        This vendored framework ensures your holocron is self-contained and doesn't depend on external framework files. All framework functionality is available locally.

        ## Upgrading

        To upgrade this framework to a newer version, run:

        ```bash
        holo upgrade
        ```

        This will update the vendored framework files to the latest version while preserving your project-specific content.
      README
    end

    def backup_framework
      return unless File.exist?(@framework_dir)

      backup_dir = "#{@framework_dir}.backup.#{Time.now.to_i}"
      FileUtils.cp_r(@framework_dir, backup_dir)
      @backup_dir = backup_dir
    end

    def restore_framework_backup
      return unless @backup_dir && File.exist?(@backup_dir)

      FileUtils.rm_rf(@framework_dir)
      FileUtils.mv(@backup_dir, @framework_dir)
      puts 'Restored framework from backup'.colorize(:yellow)
    end

    def get_latest_version(base_repo)
      # For now, return the current gem version
      # In a real implementation, this would check the remote repository
      Holocron::VERSION
    end

    def get_latest_commit(base_repo)
      # Placeholder for getting the latest commit hash
      # In a real implementation, this would query the repository
      'latest'
    end

    def count_framework_files
      return 0 unless File.exist?(@framework_dir)

      Dir.glob(File.join(@framework_dir, '**', '*')).count { |f| File.file?(f) }
    end
  end
end
