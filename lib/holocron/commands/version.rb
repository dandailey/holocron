# frozen_string_literal: true

require "colorize"

module Holocron
  module Commands
    class Version
      def call
        puts "Holocron #{Holocron::VERSION}".colorize(:green)
      end
    end
  end
end
