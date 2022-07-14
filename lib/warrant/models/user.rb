# frozen_string_literal: true

module Warrant
    class User
        attr_reader :user_id, :email, :created_at

        # @!visibility private
        def initialize(user_id, email, created_at)
            @user_id = user_id
            @email = email
            @created_at = created_at
        end

        # Creates a user with the given parameters
        #
        # @option params [String] :user_id User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        # @option params [String] :email Email address for this user. Designed to be used as a UI-friendly identifier. (optional)
        #
        # @return [User] created user
        #
        # @example Create a new User with the user id "test-customer"
        #   Warrant::User.create(user_id: "test-customer")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/users"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                User.new(res_json['userId'], res_json['email'], res_json['createdAt'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a user with given user id
        #
        # @param user_id [String] User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a User with the user id "test-customer"
        #   Warrant::User.delete("test-customer")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.delete(user_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Lists all users for your organization
        #
        # @return [Array<User>] all users for your organization
        #
        # @example List all users
        #   Warrant::User.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users"))

            case res
            when Net::HTTPSuccess
                users = JSON.parse(res.body)
                users.map{ |user| User.new(user['userId'], user['email'], user['createdAt']) }
            else
                APIOperations.raise_error(res)
            end   
        end

        # Get a user with the given user_id
        #
        # @param user_id [String] User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        #
        # @return [User] retrieved user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.get(user_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}"))

            case res
            when Net::HTTPSuccess
                user = JSON.parse(res.body)
                User.new(user['userId'], user['email'], user['createdAt'])
            else
                APIOperations.raise_error(res)
            end  
        end

        # Updates a user with the given user_id and params
        #
        # @param user_id [String] User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        # @param [Hash] params attributes to update user with
        # @option params [String] :email Email address for this user. Designed to be used as a UI-friendly identifier. (optional)
        #
        # @return [User] updated user
        #
        # @example Update user "test-user"'s email
        #   Warrant::User.update("test-user", { email: "my-new-email@example.com" })
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.update(user_id, params = {})
            res = APIOperations.put(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                User.new(res_json['userId'], res_json['email'], res_json['createdAt'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates the user with the given params
        #
        # @option params [String] :email Email address for this user. Designed to be used as a UI-friendly identifier. (optional)
        #
        # @return [User] updated user
        #
        # @example Update user "test-user"'s email
        #   user = Warrant::User.get("test-user")
        #   user.update(email: "my-new-email@example.com")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def update(params = {})
            return User.update(user_id, params)
        end

        # List all roles for a user.
        #
        # @return [Array<Role>] all roles for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def list_roles
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/roles"))

            case res
            when Net::HTTPSuccess
                roles = JSON.parse(res.body)
                roles.map{ |role| Role.new(role['roleId']) }
            else
                APIOperations.raise_error(res)
            end 
        end

        # Assign a role to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a role to.
        # @param role_id [String] The role_id of the role you want to assign to a user.
        #
        # @return [Permission] assigned role
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.assign_role("admin")
        def assign_role(role_id)
            return Role.assign_to_user(user_id, role_id)
        end

        # Remove a role from a user
        #
        # @param user_id [String] The user_id of the role you want to assign a role to.
        # @param role_id [String] The role_id of the role you want to assign to a user.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.remove_role("admin")
        def remove_role(role_id)
            return Role.remove_from_user(user_id, role_id)
        end

        # List all permissions for a user 
        #
        # @return [Array<Permission>] all permissions for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def list_permissions
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/permissions"))

            case res
            when Net::HTTPSuccess
                permissions = JSON.parse(res.body)
                permissions.map{ |permission| Permission.new(permission['permissionId']) }
            else
                APIOperations.raise_error(res)
            end 
        end

        # Assign a permission to a user
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to a user.
        #
        # @return [Permission] assigned permission
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.assign_permission("edit-report")
        def assign_permission(permission_id)
            return Permission.assign_to_user(user_id, permission_id)
        end

        # Remove a permission from a user
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to a user.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.remove_permission("edit-report")
        def remove_permission(permission_id)
            Permission.remove_from_user(user_id, permission_id)
        end

        # Checks whether a user has a given permission
        #
        # @param permission_id [String] The permission_id of the permission you want to check whether or not it exists on the user.
        #
        # @return [Boolean] whether or not the user has the given permission
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.has_permission?("edit-report")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def has_permission?(permission_id)
            return Warrant.is_authorized?(
                warrants: [{
                    object_type: "permission",
                    object_id: permission_id,
                    relation: "member",
                    subject: {
                        object_type: "user",
                        object_id: user_id
                    }
                }]
            )
        end

        # Add a user to a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to assign a user to.
        # @param user_id [String] The user_id of the user you want to add to the tenant.
        #
        # @return [Warrant] warrant assigning user to the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.add_to_tenant(tenant_id, user_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/users/#{user_id}"))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                subject = Subject.new(res_json['subject']['objectType'], res_json['subject']['objectId'])
                Warrant.new(res_json['objectType'], res_json['objectId'], res_json['relation'], subject)
            else
                APIOperations.raise_error(res)
            end 
        end

        # Remove a user from a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to remove the user from.
        # @param user_id [String] The user_id of the user you want to remove from the tenant.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_tenant(tenant_id, user_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/users/#{user_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end  
        end

        # List all users for a tenant 
        #
        # @param tenant_id [String] The tenant_id of the tenant from which to fetch users
        #
        # @return [Array<User>] all users for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.list_for_tenant(tenant_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/users"))

            case res
            when Net::HTTPSuccess
                users = JSON.parse(res.body)
                users.map{ |user| User.new(user['userId'], user['email'], user['createdAt']) }
            else
                APIOperations.raise_error(res)
            end 
        end

        # List all tenants for a user 
        #
        # @return [Array<Tenant>] all tenants for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def list_tenants
            return Tenant.list_for_user(user_id)
        end
    end
end
