# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module Holocron
  class Registry
    REGISTRY_FILE = File.expand_path('~/.holocron.yml')

    def self.load
      new.load
    end

    def initialize
      @holocrons = {}
      @default = nil
    end

    def load
      return self unless File.exist?(REGISTRY_FILE)

      data = YAML.load_file(REGISTRY_FILE)
      @default = data['default'] || data[:default]

      holocrons_data = data['holocrons'] || data[:holocrons]
      holocrons_data&.each do |holo|
        name = holo['name'] || holo[:name]
        path = holo['path'] || holo[:path]
        description = holo['description'] || holo[:description]
        active = holo['active'] || holo[:active] || false

        @holocrons[name] = {
          name: name,
          path: path,
          description: description,
          active: active
        }
      end

      self
    rescue StandardError => e
      puts "Warning: Failed to load registry: #{e.message}"
      self
    end

    def get(name)
      @holocrons[name]
    end

    def all
      @holocrons.values
    end

    def default
      @holocrons[@default] if @default
    end

    def active
      @holocrons.values.find { |h| h[:active] }
    end

    def exists?(name)
      @holocrons.key?(name)
    end

    def valid_path?(name)
      holo = get(name)
      return false unless holo

      File.exist?(File.join(holo[:path], '_memory'))
    end

    def names
      @holocrons.keys
    end

    def to_hash
      {
        default: @default,
        holocrons: @holocrons.values
      }
    end

    # Persist current registry state to disk
    def save
      FileUtils.mkdir_p(File.dirname(REGISTRY_FILE))
      File.write(REGISTRY_FILE, to_hash.to_yaml)
      self
    end

    # Register or update a holocron entry
    # attrs: { name:, path:, description: nil }
    def add(attrs)
      name = attrs[:name] || attrs['name']
      path = attrs[:path] || attrs['path']
      description = attrs[:description] || attrs['description']

      raise ArgumentError, 'name is required' unless name && !name.strip.empty?
      raise ArgumentError, 'path is required' unless path && !path.strip.empty?

      @holocrons[name] = {
        name: name,
        path: File.expand_path(path),
        description: description,
        active: false
      }

      self
    end

    # Remove a holocron by name
    def remove(name)
      return self unless @holocrons.key?(name)

      @holocrons.delete(name)
      @default = nil if @default == name
      self
    end

    # Mark a holocron as active (selected) and deactivate others
    def select(name)
      raise ArgumentError, "Unknown holocron: #{name}" unless @holocrons.key?(name)

      @holocrons.each_value { |h| h[:active] = false }
      @holocrons[name][:active] = true
      @default ||= name
      self
    end

    # Set the default holocron name (does not change active)
    def set_default(name)
      raise ArgumentError, "Unknown holocron: #{name}" unless @holocrons.key?(name)

      @default = name
      self
    end
  end
end
