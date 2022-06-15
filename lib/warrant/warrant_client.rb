# frozen_string_literal: true

module Warrant
    class WarrantClient
        class << self
            def create_tenant(tenant_id = '')
                uri = URI.parse("#{::Warrant.config.api_base}/v1/tenants")
                params = {
                    tenantId: tenant_id
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    Tenant.new(res_json['tenantId'])
                else
                    res_json
                end
            end

            def delete_tenant(tenant_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}")
                res = delete(uri)

                case res
                when Net::HTTPSuccess
                    return
                else
                    JSON.parse(res.body)
                end 
            end

            def create_user(email, user_id = '')
                uri = URI.parse("#{::Warrant.config.api_base}/v1/users")
                params = {
                    userId: user_id,
                    email: email
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    User.new(res_json['tenantId'], res_json['userId'], res_json['email'])
                else
                    res_json
                end
            end

            def delete_user(user_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}")
                res = delete(uri)

                case res
                when Net::HTTPSuccess
                    return
                else
                    JSON.parse(res.body)
                end
            end

            def create_role(role_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/roles")
                params = {
                    roleId: role_id
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    Role.new(res_json['roleId'])
                else
                    res_json
                end
            end

            def delete_role(role_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}")
                res = delete(uri)

                case res
                when Net::HTTPSuccess
                    return
                else
                    res_json
                end
            end

            def create_permission(permission_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/permissions")
                params = {
                    permissionId: permission_id
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    Permission.new(res_json['permissionId'])
                else
                    res_json
                end
            end

            def delete_permission(permission_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/permissions/#{permission_id}")
                res = delete(uri)

                case res
                when Net::HTTPSuccess
                    return
                else
                    res_json
                end
            end

            def create_warrant(object_type, object_id, relation, user)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/warrants")
                params = {
                    objectType: object_type,
                    objectId: object_id,
                    relation: relation,
                    user: Util.normalize_options(user)
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    Warrant.new(res_json['id'], res_json['objectType'], res_json['objectId'], res_json['relation'], res_json['user'])
                else
                    res_json
                end
            end

            def delete_warrant(warrant_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/warrants/#{warrant_id}")
                res = delete(uri)

                case res
                when Net::HTTPSuccess
                    return
                else
                    res_json
                end
            end

            def list_warrants(filters = {})
                query_string = ""
                unless filters.empty?
                    new_filters = Util.normalize_options(filters.compact)

                    query_string = URI.encode_www_form(new_filters) 
                end

                uri = URI.parse("#{::Warrant.config.api_base}/v1/warrants?#{query_string}")

                res = get(uri)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    res_json.map do |warrant|
                        Warrant.new(warrant['id'], warrant['objectType'], warrant['objectId'], warrant['relation'], warrant['user'])
                    end
                else
                    res_json
                end
            end

            def assign_role_to_user(user_id, role_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/roles/#{role_id}")
                res = post(uri)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    Role.new(res_json['roleId'])
                else
                    res_json
                end
            end

            def remove_role_from_user(user_id, role_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/roles/#{role_id}")
                res = delete(uri)

                case res
                when Net::HTTPSuccess
                    return
                else
                    res_json
                end
            end

            def assign_permission_to_user(user_id, permission_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/permissions/#{permission_id}")
                res = post(uri)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    Permission.new(res_json['permissionId'])
                else
                    res_json
                end
            end

            def remove_permission_from_user(user_id, permission_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/permissions/#{permission_id}")
                res = delete(uri)

                case res
                when Net::HTTPSuccess
                    return
                else
                    res_json
                end
            end

            def create_session(user_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/sessions")
                res = post(uri)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    res_json['token']
                else
                    res_json
                end
            end

            def create_self_service_session(user_id, redirect_url)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/sessions")
                params = {
                    type: "ssdash",
                    userId: user_id,
                    redirectUrl: redirect_url
                }
                res = post(uri, params)
                res_json = JSON.parse(res.body)

                case res
                when Net::HTTPSuccess
                    res_json['url']
                else
                    res_json
                end
            end

            def is_authorized(object_type, object_id, relation, user_id)
                uri = URI.parse("#{::Warrant.config.api_base}/v1/authorize")
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

            def has_permission(permission_id, user_id)
                return is_authorized("permission", permission_id, "member", user_id)
            end

            private

            def post(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                headers = {
                    "Authorization": "ApiKey #{::Warrant.config.api_key}"
                }
                http.post(uri.path, params.to_json, headers)
            end

            def delete(uri)
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                headers = {
                    "Authorization": "ApiKey #{::Warrant.config.api_key}"
                }
                http.delete(uri.path, headers)
            end

            def get(uri, params = {})
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                headers = {
                    "Authorization": "ApiKey #{::Warrant.config.api_key}"
                }
                http.get(uri, headers)
            end
        end
    end
end
