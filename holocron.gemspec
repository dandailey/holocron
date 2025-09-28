# frozen_string_literal: true

require_relative 'lib/holocron/version'

Gem::Specification.new do |spec|
  spec.name = 'holocron'
  spec.version = Holocron::VERSION
  spec.authors = ['Daniel Dailey']
  spec.email = ['daniel@daileyhome.com']

  spec.summary = 'Persistent memory framework for AI assistants working on long-form projects'
  spec.description = 'Holocron provides a structured documentation system that acts as persistent memory for AI assistants, enabling context maintenance across chat sessions and project management.'
  spec.homepage = 'https://github.com/dandailey/holocron'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/dandailey/holocron'
  spec.metadata['changelog_uri'] = 'https://github.com/dandailey/holocron/blob/main/CHANGELOG.md'

  spec.files = Dir.glob('lib/**/*.rb') + Dir.glob('exe/**/*') + Dir.glob('templates/**/*') + Dir.glob('docs/**/*.md')
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'thor', '~> 1.3'
  spec.add_dependency 'tty-file', '~> 0.10'
  spec.add_dependency 'tty-prompt', '~> 0.23'
  spec.add_dependency 'webrick', '~> 1.8'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
end
