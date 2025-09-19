# frozen_string_literal: true

require 'webrick'
require 'json'
require 'fileutils'
require 'holocron/commands/base_command'
require 'holocron/holocron_finder'
require 'holocron/registry'
require 'holocron/shell_executor'

module Holocron
  module Commands
    class Server < BaseCommand
      def initialize(action, options = {})
        super(options)
        @action = action
        @port = options[:port] || 4567
        @host = options[:host] || 'localhost'
      end

      def call
        case @action
        when 'start'
          start_server
        when 'stop'
          stop_server
        when 'status'
          show_status
        else
          puts "Unknown server action: #{@action}"
          puts "Available actions: start, stop, status"
          exit 1
        end
      end

      private

      def start_server
        # Load registry
        @registry = Registry.load
        
        puts "🚀 Starting Holocron server..."
        puts "🌐 Server running at: http://#{@host}:#{@port}"
        puts "📋 Registered Holocrons:"
        @registry.all.each do |holo|
          status = holo[:active] ? " (active)" : ""
          puts "   #{holo[:name]}: #{holo[:description]}#{status}"
        end
        puts ""
        puts "📋 Available endpoints:"
        puts "   GET  /v1/holocrons                    - List all Holocrons"
        puts "   GET  /v1/{holo-name}/status          - Get Holocron status"
        puts "   GET  /v1/{holo-name}/search?q=query  - Search content"
        puts "   GET  /v1/{holo-name}/file?path=path  - Get file content"
        puts "   GET  /v1/{holo-name}/bundle          - Get all content"
        puts "   GET  /v1/{holo-name}/shell?cmd=grep&args=pattern  - Execute shell command"
        puts ""
        puts "Press Ctrl+C to stop the server"

        begin
          puts "🔄 Starting WEBrick server..."
          server = WEBrick::HTTPServer.new(Port: @port, Host: @host)
          
          # Add signal handling
          trap('INT') { server.shutdown }
          
          # Mount registry endpoint
          server.mount_proc('/v1/holocrons') { |req, res| handle_holocrons(req, res) }
          
          # Mount dynamic Holocron endpoints
          server.mount_proc('/v1/') { |req, res| handle_holocron_request(req, res) }
          
          puts "✅ Server started successfully"
          server.start
        rescue => e
          puts "❌ Error starting server: #{e.message}"
          puts e.backtrace.first(5)
          exit 1
        rescue Interrupt
          puts "\n🛑 Server stopped"
        end
      end

      def stop_server
        puts "Server stop not implemented yet (use Ctrl+C to stop running server)"
      end

      def show_status
        puts "Server status not implemented yet"
      end


      def handle_holocrons(req, res)
        res.content_type = 'application/json'
        res.body = JSON.generate(@registry.to_hash)
      end

      def handle_holocron_request(req, res)
        res.content_type = 'application/json'
        
        # Parse path: /v1/holo-name/endpoint
        path_parts = req.path.split('/').reject(&:empty?)
        return not_found(res) if path_parts.size < 3 || path_parts[0] != 'v1'
        
        holo_name = path_parts[1]
        endpoint = path_parts[2]
        
        # Validate Holocron exists
        holo = @registry.get(holo_name)
        unless holo
          res.status = 404
          res.body = JSON.generate({ error: "Holocron '#{holo_name}' not found" })
          return
        end

        # Validate Holocron path exists
        unless @registry.valid_path?(holo_name)
          res.status = 500
          res.body = JSON.generate({ error: "Holocron '#{holo_name}' path is invalid" })
          return
        end

        # Route to appropriate handler
        case endpoint
        when 'status'
          handle_status(req, res, holo)
        when 'search'
          handle_search(req, res, holo)
        when 'file'
          handle_file(req, res, holo)
        when 'bundle'
          handle_bundle(req, res, holo)
        when 'shell'
          handle_shell(req, res, holo)
        else
          not_found(res)
        end
      end

      def handle_status(req, res, holo)
        res.body = JSON.generate({
          name: holo[:name],
          path: holo[:path],
          description: holo[:description],
          active: holo[:active],
          timestamp: Time.now.iso8601,
          endpoints: [
            "GET /v1/#{holo[:name]}/search?q=query",
            "GET /v1/#{holo[:name]}/file?path=path",
            "GET /v1/#{holo[:name]}/bundle",
            "GET /v1/#{holo[:name]}/shell?cmd=command&args=arg1,arg2"
          ]
        })
      end

      def handle_search(req, res, holo)
        query = req.query['q']
        unless query
          res.status = 400
          res.body = JSON.generate({ error: 'Query parameter "q" is required' })
          return
        end

        results = search_holocron(holo[:path], query)
        res.body = JSON.generate({ 
          holocron: holo[:name],
          query: query, 
          results: results 
        })
      end

      def handle_file(req, res, holo)
        file_path = req.query['path']
        unless file_path
          res.status = 400
          res.body = JSON.generate({ error: 'Path parameter "path" is required' })
          return
        end

        full_path = File.join(holo[:path], file_path)
        unless File.exist?(full_path)
          res.status = 404
          res.body = JSON.generate({ error: 'File not found' })
          return
        end

        content = File.read(full_path)
        res.body = JSON.generate({ 
          holocron: holo[:name],
          path: file_path, 
          content: content 
        })
      end

      def handle_bundle(req, res, holo)
        bundle = create_holocron_bundle(holo[:path])
        bundle[:holocron] = holo[:name]
        bundle[:description] = holo[:description]
        res.body = JSON.generate(bundle)
      end

      def handle_shell(req, res, holo)
        command = req.query['cmd']
        unless command
          res.status = 400
          res.body = JSON.generate({ error: 'Parameter "cmd" is required' })
          return
        end

        # Parse arguments and options
        args = req.query['args'] ? req.query['args'].split(',') : []
        options = {}
        
        # Extract option parameters (anything starting with -)
        req.query.each do |key, value|
          next if %w[cmd args].include?(key)
          options[key] = value
        end

        executor = ShellExecutor.new(holo[:path])
        result = executor.execute(command, args, options)
        
        result[:holocron] = holo[:name]
        res.body = JSON.generate(result)
      end

      def not_found(res)
        res.status = 404
        res.body = JSON.generate({ error: 'Not Found' })
      end

      def search_holocron(holocron_dir, query)
        results = []
        search_files(holocron_dir).each do |file_path|
          next unless File.exist?(file_path)
          
          content = File.read(file_path)
          if content.downcase.include?(query.downcase)
            relative_path = file_path.sub(holocron_dir + '/', '')
            results << {
              path: relative_path,
              matches: extract_matches(content, query)
            }
          end
        end
        results
      end

      def search_files(holocron_dir)
        Dir.glob(File.join(holocron_dir, '**', '*.md'))
      end

      def extract_matches(content, query)
        lines = content.split("\n")
        matches = []
        lines.each_with_index do |line, index|
          if line.downcase.include?(query.downcase)
            matches << {
              line_number: index + 1,
              line: line.strip
            }
          end
        end
        matches
      end

      def create_holocron_bundle(holocron_dir)
        bundle = {
          holocron_dir: holocron_dir,
          timestamp: Time.now.iso8601,
          files: {}
        }

        search_files(holocron_dir).each do |file_path|
          relative_path = file_path.sub(holocron_dir + '/', '')
          bundle[:files][relative_path] = File.read(file_path)
        end

        bundle
      end

      def find_holocron_directory
        HolocronFinder.find_holocron_directory('.', @options[:dir])
      end
    end
  end
end
