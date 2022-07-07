# frozen_string_literal: true

module Warrant
    # @!visibility private
    class APIOperations
        class << self
            def post(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                headers = {
                    "Authorization": "ApiKey #{::Warrant.config.api_key}"
                }
                http.post(uri.path, params.to_json, headers)
            end

            def delete(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                request = Net::HTTP::Delete.new(uri.path)
                request["Authorization"] = "ApiKey #{::Warrant.config.api_key}"

                http.request(request, params.to_json)
            end     

            def get(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                headers = {
                    "Authorization": "ApiKey #{::Warrant.config.api_key}"
                }

                unless params.empty?
                    normalized_params = Util.normalize_params(params.compact)
                    uri.query = URI.encode_www_form(normalized_params)
                end
                
                http.get(uri, headers)
            end

            def put(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                headers = {
                    "Authorization": "ApiKey #{::Warrant.config.api_key}"
                }
                http.put(uri.path, params.to_json, headers)
            end
        end
    end
end
