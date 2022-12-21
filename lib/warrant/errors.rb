# frozen_string_literal: true

module Warrant
    class Error
        DUPLICATE_RECORD_ERROR = "duplicate_record"
        FORBIDDEN_ERROR = "forbidden"
        INTERNAL_ERROR = "internal_error"
        INVALID_REQUEST_ERROR = "invalid_request"
        INVALID_PARAMETER_ERROR = "invalid_parameter"
        MISSING_REQUIRED_PARAMETER_ERROR = "missing_required_parameter"
        NOT_FOUND_ERROR = "not_found"
        UNAUTHORIZED_ERROR = "unauthorized"
    end

    class WarrantError < StandardError
        attr_reader :code, :headers, :message, :http_status, :http_headers, :http_body, :json_body

        def initialize(code = nil, message = nil, http_status = nil, http_headers = nil, http_body = nil, json_body = nil)
            @code = code
            @headers = headers
            @message = message
            @http_status = http_status
            @http_headers = http_headers
            @http_body = http_body
            @json_body = json_body
        end

        def self.initialize_error_from_response(response)
            response_json = JSON.parse(response.body)
            self.new(
                response_json['code'],
                Util.snake_case(response_json['message']),
                response.code,
                response.to_hash,
                response.body,
                response_json
            )
        end
    end

    class DuplicateRecordError < WarrantError; end
    class ForbiddenError < WarrantError; end
    class InternalError < WarrantError; end
    class InvalidRequestError < WarrantError; end
    class InvalidParameterError < WarrantError; end
    class MissingRequiredParameterError < WarrantError; end
    class NotFoundError < WarrantError; end
    class UnauthorizedError < WarrantError; end
end
