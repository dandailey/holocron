# frozen_string_literal: true

require "fileutils"
require "colorize"

module Holocron
  module Commands
    class Context
      def initialize(reason, options)
        @reason = reason || options[:why] || "Manual context refresh"
        @options = options
      end

      def new_refresh
        timestamp = Time.now.strftime("%Y_%m_%d")
        filename = "_PENDING_#{timestamp}_context_refresh.md"
        filepath = File.join("_memory", "context_refresh", filename)
        
        content = <<~CONTENT
          # Context Refresh - #{@reason}
          
          **Date:** #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}
          **Reason:** #{@reason}
          
          ## Current Objective
          <!-- What is the single next thing we intend to deliver? -->
          
          ## Key Decisions Since Last Refresh
          <!-- Link to any new entries in _memory/decision_log.md -->
          
          ## Files in Flight
          <!-- List filepaths to things currently being edited or worth reading first -->
          
          ## Blockers / Unknowns
          <!-- Anything that could bite tomorrow-you -->
          
          ## Quick Status Bullets
          <!-- Green tests? Feature flag enabled? Branch name? -->
          
          ## Next Steps
          <!-- What should future-you do first? -->
        CONTENT

        FileUtils.mkdir_p(File.dirname(filepath))
        File.write(filepath, content)
        
        puts "✅ Created context refresh file: #{filepath}".colorize(:green)
        puts "Edit the file to add details, then rename it to remove _PENDING_ prefix".colorize(:yellow)
      end
    end
  end
end
