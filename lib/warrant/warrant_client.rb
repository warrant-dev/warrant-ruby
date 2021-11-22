# frozen_string_literal: true

module Warrant
    class WarrantClient
        class << self
            def create_user(user_id = '', username = '')
                uri = URI.parse("#{Warrant.config.api_base}/v1/users")
                params = {
                    userId: user_id,
                    username: username
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)
                
                case res
                when Net::HTTPSuccess
                    User.new(res_json['userId'])
                else
                    res_json
                end
            end

            def create_warrant(object_type, object_id, relation, user)
                uri = URI.parse("#{Warrant.config.api_base}/v1/warrants")
                params = {
                    objectType: object_type,
                    objectId: object_id,
                    relation: relation,
                    user: user
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)
                
                case res
                when Net::HTTPSuccess
                    if res_json['user']['userId']
                        UserWarrant.new(res_json['objectType'], res_json['objectId'], res_json['relation'], res_json['user']['userId'])
                    elsif res_json['user']['objectType']
                        UsersetWarrant.new(res_json['objectType'], res_json['objectId'], res_json['relation'], res_json['user'])
                    end
                else
                    res_json
                end
            end

            def create_session(user_id)
                uri = URI.parse("#{Warrant.config.api_base}/v1/users/#{user_id}/sessions")
                res = post(uri)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    res_json['token']
                else
                    res_json
                end
            end

            def is_authorized(object_type, object_id, relation, user_id)
                uri = URI.parse("#{Warrant.config.api_base}/v1/authorize")
                params = {
                    objectType: object_type,
                    objectId: object_id,
                    relation: relation,
                    user: {
                        userId: user_id
                    }
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)

                if res.is_a? Net::HTTPSuccess
                    true
                else
                    false
                end
            end

            private

            def post(uri, params = {}) 
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                headers = {
                    "Authorization": "ApiKey #{Warrant.config.api_key}"
                }
                http.post(uri.path, params.to_json, headers)
            end
        end
    end
end
