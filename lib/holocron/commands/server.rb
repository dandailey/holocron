# frozen_string_literal: true

require 'webrick'
require 'json'
require 'holocron/server_app'
require 'fileutils'
require 'holocron/commands/base_command'
require 'holocron/holocron_finder'
require 'holocron/registry'
require 'holocron/operations_handler'

module Holocron
  module Commands
    class Server < BaseCommand
      def initialize(action, options = {})
        super(options)
        @action = action
        @port = options[:port] || 4567
        @host = options[:host] || 'localhost'
        @background = options[:background] || false
        @adapter = (options[:adapter] || 'webrick').to_s
        @rackup = options[:rackup]
        @pid_file = File.expand_path('~/.holocron_server.pid')
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
          puts 'Available actions: start, stop, status'
          exit 1
        end
      end

      private

      def start_server
        # Check if server is already running
        if server_running?
          puts "⚠️  Server is already running (PID: #{read_pid})"
          puts "   Use 'holo server stop' to stop it first"
          return
        end

        # Load registry
        @registry = Registry.load

        if @background
          start_background_server
        else
          start_foreground_server
        end
      end

      def start_foreground_server
        puts '🚀 Starting Holocron server...'
        puts "🌐 Server running at: http://#{@host}:#{@port}"
        puts '📋 Registered Holocrons:'
        @registry.all.each do |holo|
          status = holo[:active] ? ' (active)' : ''
          puts "   #{holo[:name]}: #{holo[:description]}#{status}"
        end
        puts ''
        puts '📋 Available endpoints:'
        puts '   GET  /v1/holocrons                           - List all Holocrons'
        puts '   GET  /v1/{holo-name}/status                  - Get Holocron status'
        puts ''
        puts '📋 Operations API:'
        puts '   GET/POST /v1/{holo-name}/ops/list_files     - List files with filters'
        puts '   GET      /v1/{holo-name}/ops/read_file      - Read file content'
        puts '   PUT      /v1/{holo-name}/ops/put_file       - Create/update file'
        puts '   DELETE   /v1/{holo-name}/ops/delete_file    - Delete file'
        puts '   POST     /v1/{holo-name}/ops/search         - Search with context'
        puts '   POST     /v1/{holo-name}/ops/move_file      - Move/rename file'
        puts '   POST     /v1/{holo-name}/ops/bundle         - Bundle multiple files'
        puts ''
        puts 'Press Ctrl+C to stop the server'
        start_rack_server
      end

      def start_background_server
        puts '🚀 Starting Holocron server in background...'

        # Fork to background
        pid = Process.fork do
          # Detach from parent process
          Process.setsid

          # Redirect output to log file
          log_file = File.expand_path('~/.holocron_server.log')
          $stdout.reopen(log_file, 'a')
          $stderr.reopen(log_file, 'a')

          # Start the server
          start_rack_server
        end

        # Detach the child process so parent doesn't wait for it
        Process.detach(pid)

        # Save PID
        write_pid(pid)

        # Give server a moment to start
        sleep 2

        if server_running?
          puts "✅ Server started successfully (PID: #{pid})"
          puts "🌐 Server running at: http://#{@host}:#{@port}"
          puts '📝 Logs: ~/.holocron_server.log'
          puts '🛑 Stop with: holo server stop'
        else
          puts '❌ Failed to start server'
          File.delete(@pid_file) if File.exist?(@pid_file)
        end
      end

      def stop_server
        unless server_running?
          puts 'ℹ️  No server is currently running'
          return
        end

        pid = read_pid
        puts "🛑 Stopping server (PID: #{pid})..."

        begin
          Process.kill('TERM', pid)
          # Wait for graceful shutdown
          sleep 2

          if server_running?
            puts "⚠️  Server didn't stop gracefully, forcing..."
            Process.kill('KILL', pid)
            sleep 1
          end

          File.delete(@pid_file) if File.exist?(@pid_file)
          puts '✅ Server stopped successfully'
        rescue Errno::ESRCH
          puts 'ℹ️  Server was not running'
          File.delete(@pid_file) if File.exist?(@pid_file)
        rescue StandardError => e
          puts "❌ Error stopping server: #{e.message}"
        end
      end

      def show_status
        if server_running?
          pid = read_pid
          puts "✅ Server is running (PID: #{pid})"
          puts "🌐 Server URL: http://#{@host}:#{@port}"
          puts '📝 Logs: ~/.holocron_server.log'
          puts "📁 PID file: #{@pid_file}"

          # Show uptime
          begin
            process = `ps -p #{pid} -o etime=`.strip
            puts "⏱️  Uptime: #{process}" unless process.empty?
          rescue StandardError
            # Ignore errors getting uptime
          end

          # Test server connectivity
          puts "\n🔍 Testing server connectivity..."
          begin
            require 'net/http'
            require 'uri'
            uri = URI("http://#{@host}:#{@port}/v1/help")
            response = Net::HTTP.get_response(uri)
            if response.code == '200'
              puts '✅ Server is responding to requests'
            else
              puts "⚠️  Server is running but not responding properly (HTTP #{response.code})"
            end
          rescue StandardError => e
            puts "❌ Server is not responding: #{e.message}"
          end

          # Show registered holocrons
          puts "\n📋 Registered Holocrons:"
          begin
            @registry = Registry.load
            if @registry.all.any?
              @registry.all.each do |holo|
                status = holo[:active] ? ' (active)' : ''
                puts "   #{holo[:name]}: #{holo[:description] || 'No description'}#{status}"
              end
            else
              puts '   No holocrons registered'
            end
          rescue StandardError => e
            puts "   Error loading registry: #{e.message}"
          end

        else
          puts '❌ Server is not running'
          puts "📁 PID file: #{@pid_file}"
          puts '⚠️  Stale PID file found - you may want to clean it up' if File.exist?(@pid_file)
        end
      end

      def start_rack_server
        case @adapter
        when 'webrick', nil, ''
          start_webrick_server
          nil
        when 'puma'
          begin
            require 'rack'
            require 'rack/handler/puma'
          rescue LoadError
            puts '⚠️  Puma not available. Falling back to WEBrick.'
            start_webrick_server
            return
          end

          app = Holocron::ServerApp.new(host: @host, port: @port)
          trap('INT') { exit }
          puts '✅ Server started successfully'
          Rack::Handler::Puma.run(app, Host: @host, Port: @port)
        else
          puts "⚠️  Unknown adapter '#{@adapter}', using WEBrick."
          start_webrick_server
        end
      rescue StandardError => e
        puts "❌ Error starting server: #{e.message}"
        puts e.backtrace.first(5)
        exit 1
      rescue Interrupt
        puts "\n🛑 Server stopped"
      end

      def start_webrick_server
        server = WEBrick::HTTPServer.new(Port: @port, Host: @host)

        trap('INT') { server.shutdown }

        WEBrick::HTTPServlet::ProcHandler.class_eval do
          def do_DELETE(req, res)
            @proc.call(req, res)
          end

          def do_PUT(req, res)
            @proc.call(req, res)
          end
        end

        server.mount_proc('/v1/holocrons') { |req, res| handle_holocrons(req, res) }
        server.mount_proc('/v1/help') { |req, res| handle_help(req, res, nil) }
        server.mount_proc('/v1/') { |req, res| handle_holocron_request(req, res) }

        puts '✅ Server started successfully'
        server.start
      rescue StandardError => e
        puts "❌ Error starting server: #{e.message}"
        puts e.backtrace.first(5)
        exit 1
      rescue Interrupt
        puts "\n🛑 Server stopped"
      end

      def server_running?
        return false unless File.exist?(@pid_file)

        pid = read_pid
        return false unless pid

        Process.kill(0, pid)
        true
      rescue Errno::ESRCH, Errno::ENOENT
        false
      end

      def read_pid
        return nil unless File.exist?(@pid_file)

        File.read(@pid_file).strip.to_i
      end

      def write_pid(pid)
        File.write(@pid_file, pid.to_s)
      end

      def handle_holocrons(_req, res)
        res.content_type = 'application/json'
        res.body = JSON.generate(@registry.to_hash)
      end

      def handle_holocron_request(req, res)
        res.content_type = 'application/json'

        # Parse path: /v1/holo-name/endpoint or /v1/holo-name/ops/operation
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

        # /v1/{holo}/help
        if endpoint == 'help'
          handle_help(req, res, holo)
          return
        end

        # Handle operations API
        if endpoint == 'ops' && path_parts.size >= 4
          operation = path_parts[3]
          handle_operation(req, res, holo, operation)
          return
        end

        # Handle status endpoint (keep this one as it's useful for health checks)
        if endpoint == 'status'
          handle_status(req, res, holo)
          return
        end

        # Everything else is not found
        not_found(res)
      end

      def handle_help(_req, res, holo)
        res.content_type = 'text/markdown'
        name = holo ? holo[:name] : '{holo}'
        ops_base = "/v1/#{name}/ops"
        md = <<~MD
          # Holocron Web Service — Operations API Help

          This is a HTTP‑first API for reading and writing files within a Holocron. It uses named parameters and JSON bodies.

          - Base URL: `http://#{@host}:#{@port}`
          - Holocron: `#{name}`
          - Operations base: `#{ops_base}`

          ## Quick Start

          - List files:
            ```bash
            curl -s "#{ops_base}/list_files?limit=5"
            ```

          - Read a file:
            ```bash
            curl -s "#{ops_base}/read_file?path=README.md"
            ```

          - Search with context:
            ```bash
            curl -s -X POST -H "Content-Type: application/json" \
              -d '{"query":"memory","before":1,"after":1}' \
              "#{ops_base}/search"
            ```

          - Create or replace a file:
            ```bash
            curl -s -X PUT -H "Content-Type: application/json" \
              -d '{"path":"docs/demo.md","content":"Hello world"}' \
              "#{ops_base}/put_file"
            ```

          - Delete a file (with precondition):
            ```bash
            sha=$(curl -s "#{ops_base}/read_file?path=docs/demo.md" | jq -r .sha256)
            curl -s -X DELETE -H "Content-Type: application/json" \
              -d "{\"path\":\"docs/demo.md\",\"if_match_sha256\":\"$sha\"}" \
              "#{ops_base}/delete_file"
            ```

          ## Operations

          ### list_files
          - Method: GET or POST `#{ops_base}/list_files`
          - Purpose: Enumerate files using filters
          - Params/Body:
            - `dir` (string, default `.`)
            - `include_glob[]` (string[]), e.g. `**/*.md`
            - `exclude_glob[]` (string[])
            - `extensions[]` (string[]), e.g. `["md","rb"]`
            - `max_depth` (int)
            - `sort` (`path|mtime|size`, default `path`), `order` (`asc|desc`)
            - `limit`, `offset` (ints)

          ### read_file
          - Method: GET `#{ops_base}/read_file`
          - Params: `path` (required), `offset` (lines), `limit` (lines)
          - Returns: `{ path, size, mtime, content, sha256 }`

          ### search
          - Method: POST `#{ops_base}/search`
          - Body: `query` (required), `regex` (bool), `case` (`sensitive|insensitive`), `before` (int), `after` (int), plus file filters
          - Returns: per‑file matches with surrounding context lines

          ### put_file
          - Method: PUT `#{ops_base}/put_file`
          - Body: `path` (required), `content` (required), `encoding` (`plain|base64`), `if_match_sha256`, `author`, `message`
          - Notes: If `if_match_sha256` is provided and does not match the current file hash, returns 412.

          ### delete_file
          - Method: DELETE `#{ops_base}/delete_file`
          - Body: `path` (required), `if_match_sha256` (optional)

          ### move_file
          - Method: POST `#{ops_base}/move_file`
          - Body: `from` (required), `to` (required), `if_match_sha256` (optional), `overwrite` (bool)

          ### bundle
          - Method: POST `#{ops_base}/bundle`
          - Body: `paths[]` or file filters, `max_total_bytes` (default 1_000_000)

          ### apply_diff
          - Method: POST `#{ops_base}/apply_diff`
          - Purpose: Apply git-style unified diff to multiple files atomically
          - Body: `{ diff: "unified diff content", author?, message? }`
          - Returns: `{ applied: bool, summary: { total_files, created, modified, deleted, hunks_applied, errors }, results: [...] }`
          - Example:
            ```bash
            curl -s -X POST -H "Content-Type: application/json" \
              -d '{"diff":"--- a/_memory/progress_logs/new.md\n+++ b/_memory/progress_logs/new.md\n@@ -0,0 +1,5 @@\n+# New Entry\n+Content here"}' \
              "#{ops_base}/apply_diff"
            ```

          ## Safety & Sandbox
          - All paths are sandboxed within the Holocron root; traversal outside is prevented.
          - Precondition writes via `if_match_sha256` prevent accidental overwrites.

          ## Full Design Doc
          See `web_service_plan.md` in `.holocron/sync/` of the project repository for the complete specification.
        MD
        res.body = md
      end

      def handle_status(_req, res, holo)
        res.body = JSON.generate({
                                   name: holo[:name],
                                   path: holo[:path],
                                   description: holo[:description],
                                   active: holo[:active],
                                   timestamp: Time.now.iso8601,
                                   endpoints: [
                                     "GET/POST /v1/#{holo[:name]}/ops/list_files",
                                     "GET /v1/#{holo[:name]}/ops/read_file?path=filename",
                                     "PUT /v1/#{holo[:name]}/ops/put_file",
                                     "DELETE /v1/#{holo[:name]}/ops/delete_file",
                                     "POST /v1/#{holo[:name]}/ops/search",
                                     "POST /v1/#{holo[:name]}/ops/move_file",
                                     "POST /v1/#{holo[:name]}/ops/bundle"
                                   ]
                                 })
      end

      def handle_operation(req, res, holo, operation)
        # Parse query parameters and request body
        params = req.query || {}
        body = {}

        # Parse JSON body for POST/PUT/DELETE requests
        if %w[POST PUT DELETE].include?(req.request_method) && req.body
          begin
            body_content = req.body.to_s
            body = JSON.parse(body_content) unless body_content.empty?
          rescue JSON::ParserError => e
            res.status = 400
            res.body = JSON.generate({ error: "Invalid JSON: #{e.message}" })
            return
          end
        end

        # Initialize operations handler
        ops_handler = OperationsHandler.new(holo[:path])

        # Handle the operation
        result = ops_handler.handle_operation(operation, req.request_method, params, body)

        # Set status code if error
        res.status = result[:status] || 400 if result[:error]

        res.body = JSON.generate(result)
      end

      def not_found(res)
        res.status = 404
        res.body = JSON.generate({ error: 'Not Found' })
      end
    end
  end
end
