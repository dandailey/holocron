# frozen_string_literal: true

require 'json'
require 'rack'
require 'holocron/registry'
require 'holocron/operations_handler'

module Holocron
  # Rack application exposing Holocron HTTP API
  class ServerApp
    def initialize(host: 'localhost', port: 4567)
      @host = host
      @port = port
      @registry = Registry.load
    end

    def call(env)
      req = Rack::Request.new(env)
      path = req.path_info

      return ok_json(@registry.to_hash) if req.get? && path == '/v1/holocrons'

      # Content negotiation for help
      if req.get? && path == '/v1/help'
        return ok_markdown(help_markdown(nil)) unless req.env['HTTP_ACCEPT']&.include?('application/json')

        return ok_json({
                         docs: {
                           hub: 'docs/index.md',
                           parity: 'docs/ops/index.md',
                           guides: 'docs/guides/'
                         },
                         base_url: "http://#{@host}:#{@port}",
                         api_version: 'v1'
                       })

      end

      # Match /v1/:holo/... endpoints
      parts = path.split('/').reject(&:empty?)
      return not_found unless parts[0] == 'v1' && parts.size >= 2

      holo_name = parts[1]
      holo = @registry.get(holo_name)
      return error_json(404, "Holocron '#{holo_name}' not found") unless holo
      return error_json(500, "Holocron '#{holo_name}' path is invalid") unless @registry.valid_path?(holo_name)

      return ok_markdown(help_markdown(holo)) if parts[2] == 'help'

      if parts[2] == 'status'
        return ok_json({
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

      if parts[2] == 'ops' && parts.size >= 4
        operation = parts[3]
        return handle_operation(req, holo, operation)
      end

      not_found
    rescue StandardError => e
      error_json(500, "Internal error: #{e.message}")
    end

    private

    def handle_operation(req, holo, operation)
      params = req.GET.dup
      body = {}
      if %w[POST PUT DELETE].include?(req.request_method)
        raw = req.body.read
        req.body.rewind
        body = JSON.parse(raw) unless raw.nil? || raw.empty?
      end

      ops_handler = OperationsHandler.new(holo[:path])
      result = ops_handler.handle_operation(operation, req.request_method, params, body)
      status = result[:error] ? (result[:status] || 400) : 200
      [status, { 'Content-Type' => 'application/json' }, [JSON.generate(result)]]
    rescue JSON::ParserError => e
      error_json(400, "Invalid JSON: #{e.message}")
    end

    def ok_json(obj)
      [200, { 'Content-Type' => 'application/json' }, [JSON.generate(obj)]]
    end

    def ok_markdown(md)
      [200, { 'Content-Type' => 'text/markdown' }, [md]]
    end

    def not_found
      error_json(404, 'Not Found')
    end

    def error_json(status, message)
      [status, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: message, status: status })]]
    end

    def help_markdown(holo)
      name = holo ? holo[:name] : '{holo}'
      ops_base = "/v1/#{name}/ops"
      <<~MD
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

        ## Safety & Sandbox
        - All paths are sandboxed within the Holocron root; traversal outside is prevented.
        - Precondition writes via `if_match_sha256` prevent accidental overwrites.
      MD
    end
  end
end
