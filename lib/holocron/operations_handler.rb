# frozen_string_literal: true

require 'json'
require_relative 'ops/base_operation'
require_relative 'ops/list_files'
require_relative 'ops/read_file'
require_relative 'ops/put_file'
require_relative 'ops/delete_file'
require_relative 'ops/search'
require_relative 'ops/move_file'
require_relative 'ops/bundle_files'
require_relative 'ops/apply_diff'
require_relative 'ops/doc_get'
require_relative 'ops/doc_update'
require_relative 'ops/progress_add'
require_relative 'ops/progress_list'
require_relative 'ops/decision_add'
require_relative 'ops/decision_list'

module Holocron
  class OperationsHandler
    def initialize(holocron_path)
      @holocron_path = File.expand_path(holocron_path)
    end

    def handle_operation(operation, method, params = {}, body = {})
      # Merge params and body for convenience
      data = params.merge(body)

      case operation
      when 'list_files'
        Ops::ListFiles.new(@holocron_path).call(data)
      when 'read_file'
        Ops::ReadFile.new(@holocron_path).call(data)
      when 'put_file'
        return error_response('PUT method required', 405) unless method == 'PUT'

        Ops::PutFile.new(@holocron_path).call(data)
      when 'delete_file'
        return error_response('DELETE method required', 405) unless method == 'DELETE'

        Ops::DeleteFile.new(@holocron_path).call(data)
      when 'search'
        return error_response('POST method required', 405) unless method == 'POST'

        Ops::Search.new(@holocron_path).call(data)
      when 'move_file'
        return error_response('POST method required', 405) unless method == 'POST'

        Ops::MoveFile.new(@holocron_path).call(data)
      when 'bundle'
        return error_response('POST method required', 405) unless method == 'POST'

        Ops::BundleFiles.new(@holocron_path).call(data)
      when 'apply_diff'
        return error_response('POST method required', 405) unless method == 'POST'

        Ops::ApplyDiff.new(@holocron_path).call(data)
      when 'doc_get'
        return error_response('GET method required', 405) unless method == 'GET'

        Ops::DocGet.new(@holocron_path).call(data)
      when 'doc_update'
        return error_response('PUT method required', 405) unless method == 'PUT'

        Ops::DocUpdate.new(@holocron_path).call(data)
      when 'progress_add'
        return error_response('POST method required', 405) unless method == 'POST'

        Ops::ProgressAdd.new(@holocron_path).call(data)
      when 'progress_list'
        return error_response('GET method required', 405) unless method == 'GET'

        Ops::ProgressList.new(@holocron_path).call(data)
      when 'decision_add'
        return error_response('POST method required', 405) unless method == 'POST'

        Ops::DecisionAdd.new(@holocron_path).call(data)
      when 'decision_list'
        return error_response('GET method required', 405) unless method == 'GET'

        Ops::DecisionList.new(@holocron_path).call(data)
      else
        error_response("Unknown operation: #{operation}", 404)
      end
    rescue StandardError => e
      error_response("Internal error: #{e.message}", 500)
    end

    private

    def error_response(message, status = 400)
      {
        error: message,
        status: status
      }
    end
  end
end
