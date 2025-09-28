# frozen_string_literal: true

require 'holocron/commands/base_command'

module Holocron
  module Commands
    class Upgrade < BaseCommand
      def call
        puts 'Holocron Upgrade'
        puts '=================================================='
        puts
        puts 'This upgrade is designed to be executed by an AI assistant.'.dup
        puts 'We do not perform file moves automatically in this version.'.dup
        puts
        puts 'Recommended next step (copy/paste to your AI in a fresh context window):'.dup
        puts
        prompt = <<~PROMPT
          You are tasked with upgrading a Holocron at:
          #{holocron_directory}

          1) Read the upgrade guide in this project: docs/guides/upgrade_0_1_to_0_2.md
          2) Follow the guide to upgrade this Holocron to version 0.2.0
          3) Produce a brief plan, execute it, and validate the result

          Important:
          - Use a fresh context window
          - Do not assume layout details; rely on the guide
          - After completion, write HOLOCRON.json with { "version": "0.2.0" }
        PROMPT
        puts prompt
        puts '=================================================='
      end
    end
  end
end
