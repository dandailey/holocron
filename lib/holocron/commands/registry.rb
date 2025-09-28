# frozen_string_literal: true

require 'colorize'
require 'holocron/registry'
require 'holocron/path_resolver'

module Holocron
  module Commands
    class RegistryCmd
      def initialize(action, options)
        @action = action
        @options = options
        @registry = Holocron::Registry.load
      end

      def call
        case @action
        when 'list'
          list
        when 'select'
          select(@options[:name])
        when 'register'
          register(@options[:name], @options[:directory])
        when 'forget'
          forget(@options[:name])
        else
          puts "Unknown registry action: #{@action}".colorize(:red)
          exit 1
        end
      end

      private

      def list
        holos = @registry.all
        if holos.empty?
          puts 'No holocrons registered yet.'
          return
        end

        active_name = @registry.active&.dig(:name)
        default_name = @registry.default&.dig(:name)

        holos.each do |h|
          flags = []
          flags << 'active' if h[:name] == active_name
          flags << 'default' if h[:name] == default_name
          tag = flags.empty? ? '' : " (#{flags.join(', ')})"
          puts "- #{h[:name]}: #{h[:path]}#{tag}"
        end
      end

      def select(name)
        unless @registry.exists?(name)
          puts "Holocron not found: #{name}".colorize(:red)
          suggest = @registry.names.any? ? "Known: #{@registry.names.join(', ')}" : 'No holocrons registered'
          puts suggest.colorize(:yellow)
          exit 1
        end

        unless @registry.valid_path?(name)
          puts "Registered path is invalid for '#{name}'. Update or re-init.".colorize(:red)
          exit 1
        end

        @registry.select(name).save
        puts "Selected holocron: #{name}".colorize(:green)
      end

      def register(name, directory)
        if name.nil? || directory.nil?
          puts 'Usage: holo register <name> <directory>'.colorize(:yellow)
          exit 2
        end

        expanded = File.expand_path(directory)
        unless PathResolver.valid_holocron_directory?(expanded)
          puts "Directory is not a valid holocron: #{expanded}".colorize(:red)
          exit 1
        end

        @registry.add(name: name, path: expanded).save
        puts "Registered holocron '#{name}' -> #{expanded}".colorize(:green)
      end

      def forget(name)
        if name.nil?
          puts 'Usage: holo forget <name>'.colorize(:yellow)
          exit 2
        end

        unless @registry.exists?(name)
          puts "Holocron not found: #{name}".colorize(:red)
          exit 1
        end

        @registry.remove(name).save
        puts "Removed holocron: #{name}".colorize(:green)
      end
    end
  end
end
