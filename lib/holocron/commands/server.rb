# frozen_string_literal: true

require 'webrick'
require 'json'
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
        # Load registry
        @registry = Registry.load

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

        begin
          puts '🔄 Starting WEBrick server...'
          server = WEBrick::HTTPServer.new(Port: @port, Host: @host)

          # Add signal handling
          trap('INT') { server.shutdown }

          # Enable DELETE method for proc handlers
          WEBrick::HTTPServlet::ProcHandler.class_eval do
            def do_DELETE(req, res)
              @proc.call(req, res)
            end

            def do_PUT(req, res)
              @proc.call(req, res)
            end
          end

          # Mount registry endpoint
          server.mount_proc('/v1/holocrons') { |req, res| handle_holocrons(req, res) }
          server.mount_proc('/v1/help') { |req, res| handle_help(req, res, nil) }

          # Mount dynamic Holocron endpoints with all HTTP methods
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
      end

      def stop_server
        puts 'Server stop not implemented yet (use Ctrl+C to stop running server)'
      end

      def show_status
        puts 'Server status not implemented yet'
      end

      def handle_holocrons(req, res)
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

      def handle_help(req, res, holo)
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

          ## Safety & Sandbox
          - All paths are sandboxed within the Holocron root; traversal outside is prevented.
          - Precondition writes via `if_match_sha256` prevent accidental overwrites.

          ## Full Design Doc
          See `web_service_plan.md` in `.holocron/sync/` of the project repository for the complete specification.
        MD
        res.body = md
      end

      def handle_status(req, res, holo)
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
