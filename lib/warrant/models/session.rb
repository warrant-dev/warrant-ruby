# frozen_string_literal: true

module Warrant
    class Session
        attr_reader :user_id, :token

        # @!visibility private
        def initialize(user_id, token)
            @user_id = user_id
            @token = token
        end

        # Create an Authorization or Self-Service Dashboard session for a given user
        #
        # @option params [String] :type Type of session to be created. (Either "sess" or "ssdash")
        # @option params [String] :user_id Id of the user to create a session for.
        # @option params [Integer] :ttl Number of seconds a session should live for. By default session tokens live for 24 hours and self service tokens live for 30 minutes.
        # 
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/sessions"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Session.new(res_json['userId'], res_json['token'])
            else
                APIOperations.raise_error(res)
            end
        end
    end
end
