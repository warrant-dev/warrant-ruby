# frozen_string_literal: true

module Warrant
    class Role
        attr_reader :role_id

        # @!visibility private
        def initialize(role_id)
            @role_id = role_id
        end

        # Creates a role with the given parameters
        #
        # @option params [String] :role_id A string identifier for this new role. The role_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'. (optional)
        #
        # @return [Role] created role
        #
        # @example Create a new Role with the role id "test-role"
        #   Warrant::Role.create(role_id: "test-role")
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
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/roles"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Role.new(res_json['roleId'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a role with given role id
        #
        # @param role_id [String] A string identifier for this new role. The role_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a Role with the role id "test-role"
        #   Warrant::Role.delete("test-role")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.delete(role_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Lists all roles for your organization
        #
        # @return [Array<Role>] all roles for your organization
        #
        # @example List all roles
        #   Warrant::Role.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/roles"))

            case res
            when Net::HTTPSuccess
                roles = JSON.parse(res.body)
                roles.map{ |role| Role.new(role['roleId']) }
            else
                APIOperations.raise_error(res)
            end   
        end

        # Get a role with the given role_id
        #
        # @param role_id [String] A string identifier for this new role. The role_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'.
        #
        # @return [Role] retrieved role
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.get(role_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}"))

            case res
            when Net::HTTPSuccess
                role = JSON.parse(res.body)
                Role.new(role['roleId'])
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
        def self.assign_to_user(user_id, role_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/roles/#{role_id}"))

            case res
            when Net::HTTPSuccess
                role = JSON.parse(res.body)
                Role.new(role['permissionId'])
            else
                APIOperations.raise_error(res)
            end  
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
        def self.remove_from_user(user_id, role_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/roles/#{role_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end  
        end

        # Assign a permission to a role
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to a role.
        #
        # @return [Permission] assigned permission
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def assign_permission(permission_id)
            return Permission.assign_to_role(role_id, permission_id)
        end

        # Remove a permission from a role
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to a role.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_permission(permission_id)
            return Permission.remove_from_role(role_id, permission_id)
        end
    end
end
