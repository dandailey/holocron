# frozen_string_literal: true

require 'colorize'
require 'holocron/documentation_loader'

module Holocron
  module Commands
    class Framework
      def initialize(options = {})
        @options = options
      end

      def call
        puts Holocron::DocumentationLoader.framework_guide.colorize(:blue)
      end
    end
  end
end
