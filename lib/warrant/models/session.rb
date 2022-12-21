# frozen_string_literal: true

module Warrant
    class Session
        # Create an Authorization Session for a given user
        #
        # @option params [String] :user_id Id of the user to create a session for.
        # @option params [Integer] :ttl Number of seconds a session should live for. By default session tokens live for 24 hours and self service tokens live for 30 minutes.
        #
        # @return [String] Session token
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.create_authorization_session(params = {})
            params = params.merge(type: "sess")
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/sessions"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                res_json['token']
            else
                APIOperations.raise_error(res)
            end
        end

        # Create a Self-Service Dashboard Session for a given user
        #
        # @param redirect_url [String] URL to redirect to once self-service session is created
        # @option params [String] :user_id Id of the user to create a session for.
        # @option params [String] :tenant_id Id of the tenant to create a session for
        # @option params [Integer] :ttl Number of seconds a session should live for. By default session tokens live for 24 hours and self service tokens live for 30 minutes.
        #
        # @return [String] URL to the self service dashboard
        #
        # @raise [Warrant::ForbiddenError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.create_self_service_session(redirect_url, params = {})
            params = params.merge(type: "ssdash")
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/sessions"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                "#{::Warrant.config.self_service_dash_url_base}/#{res_json['token']}?redirectUrl=#{redirect_url}"
            else
                APIOperations.raise_error(res)
            end
        end
    end
end
