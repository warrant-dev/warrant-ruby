# frozen_string_literal: true

module Warrant
    # @!visibility private
    class APIOperations
        class << self
            def post(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = ::Warrant.config.use_ssl
                headers = {
                    "User-Agent": "warrant-ruby/#{VERSION}"
                }
                headers["Authorization"] = "ApiKey #{::Warrant.config.api_key}" unless ::Warrant.config.api_key.empty?
                http.post(uri.path, params.to_json, headers)
            end

            def delete(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = ::Warrant.config.use_ssl
                request = Net::HTTP::Delete.new(uri.path)
                request["Authorization"] = "ApiKey #{::Warrant.config.api_key}" unless ::Warrant.config.api_key.empty?
                request["User-Agent"] = "warrant-ruby/#{VERSION}"

                http.request(request, params.to_json)
            end

            def get(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = ::Warrant.config.use_ssl
                headers = {
                    "User-Agent": "warrant-ruby/#{VERSION}"
                }
                headers["Authorization"] = "ApiKey #{::Warrant.config.api_key}" unless ::Warrant.config.api_key.empty?

                unless params.empty?
                    normalized_params = Util.normalize_params(params.compact)
                    uri.query = URI.encode_www_form(normalized_params)
                end

                http.get(uri, headers)
            end

            def put(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = ::Warrant.config.use_ssl
                headers = {
                    "User-Agent": "warrant-ruby/#{VERSION}"
                }
                headers["Authorization"] = "ApiKey #{::Warrant.config.api_key}" unless ::Warrant.config.api_key.empty?
                http.put(uri.path, params.to_json, headers)
            end

            def raise_error(response)
                error_code = JSON.parse(response.body)['code']

                case error_code
                when Error::DUPLICATE_RECORD_ERROR
                    raise DuplicateRecordError.initialize_error_from_response(response)
                when Error::FORBIDDEN_ERROR
                    raise ForbiddenError.initialize_error_from_response(response)
                when Error::INTERNAL_ERROR
                    raise InternalError.initialize_error_from_response(response)
                when Error::INVALID_REQUEST_ERROR
                    raise InvalidRequestError.initialize_error_from_response(response)
                when Error::INVALID_PARAMETER_ERROR
                    raise InvalidParameterError.initialize_error_from_response(response)
                when Error::MISSING_REQUIRED_PARAMETER_ERROR
                    raise MissingRequiredParameterError.initialize_error_from_response(response)
                when Error::NOT_FOUND_ERROR
                    raise NotFoundError.initialize_error_from_response(response)
                when Error::UNAUTHORIZED_ERROR
                    raise UnauthorizedError.initialize_error_from_response(response)
                when Error::UNKNOWN_ORIGIN_ERROR
                    raise UnknownOriginError.initialize_error_from_response(response)
                else
                    raise WarrantError.initialize_error_from_response(response)
                end
            end
        end
    end
end
