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
      @default = data['default']
      
      data['holocrons']&.each do |holo|
        @holocrons[holo['name']] = {
          name: holo['name'],
          path: holo['path'],
          description: holo['description'],
          active: holo['active'] || false
        }
      end

      self
    rescue => e
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
  end
end
