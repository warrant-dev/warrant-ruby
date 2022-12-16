# frozen_string_literal: true

module Warrant
    class Role
        attr_reader :role_id, :name, :description

        # @!visibility private
        def initialize(role_id, name = nil, description = nil)
            @role_id = role_id
            @name = name
            @description = description
        end

        # Creates a role with the given parameters
        #
        # @option params [String] :role_id A string identifier for this new role. The role_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'.
        #
        # @return [Role] created role
        #
        # @example Create a new Role with the role id "test-role"
        #   Warrant::Role.create(role_id: "test-role")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/roles"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Role.new(res_json['roleId'], res_json['name'], res_json['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a role with given role id
        #
        # @param role_id [String] The role_id of the role to delete.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a Role with the role id "test-role"
        #   Warrant::Role.delete("test-role")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
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
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/roles"))

            case res
            when Net::HTTPSuccess
                roles = JSON.parse(res.body)
                roles.map{ |role| Role.new(role['roleId'], role['name'], role['description']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Get a role with the given role_id
        #
        # @param role_id [String] The role_id of the role to retrieve.
        #
        # @return [Role] retrieved role
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.get(role_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}"))

            case res
            when Net::HTTPSuccess
                role = JSON.parse(res.body)
                Role.new(role['roleId'], role['name'], role['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates a role with the given role_id and params
        #
        # @param role_id [String] The role_id of the role to be updated.
        # @param [Hash] params attributes to update user with
        # @option params [String] :name Name for the role. Designed to be used as a UI-friendly identifier. (optional)
        # @option params [String] :description Description of the role. Designed to be used as a UI-friendly identifier. (optional)
        #
        # @return [Role] updated role
        #
        # @example Update role "test-role"'s name
        #   Warrant::Role.update("test-role", { name: "Test Role" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.update(role_id, params = {})
            res = APIOperations.put(URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Role.new(res_json['roleId'], res_json['name'], res_json['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates a role with the given params
        #
        # @param [Hash] params attributes to update user with
        # @option params [String] :name Name for the role. Designed to be used as a UI-friendly identifier. (optional)
        # @option params [String] :description Description of the role. Designed to be used as a UI-friendly identifier. (optional)
        #
        # @return [Role] updated role
        #
        # @example Update role "test-role"'s name
        #   Warrant::Role.update("test-role", { name: "Test Role" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(params = {})
            res = APIOperations.put(URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Role.new(res_json['roleId'], res_json['name'], res_json['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # List roles for user
        #
        # @param user_id [String] The user_id of the user you want to retrieve roles for.
        #
        # @return [Array<Role>] all assigned roles for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_user(user_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/roles"))

            case res
            when Net::HTTPSuccess
                roles = JSON.parse(res.body)
                roles.map{ |role| Role.new(role['roleId'], role['name'], role['description']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Assign a role to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a role to.
        # @param role_id [String] The role_id of the role you want to assign to a user.
        #
        # @return [Role] assigned role
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_user(user_id, role_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/roles/#{role_id}"))

            case res
            when Net::HTTPSuccess
                role = JSON.parse(res.body)
                Role.new(role['roleId'], role['name'], role['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Remove a role from a user
        #
        # @param user_id [String] The user_id of the role you want to remove a role from.
        # @param role_id [String] The role_id of the role you want to remove from a user.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::ForbiddenError]
        # @raise [Warrant::InternalError]
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

        # List assigned permissions for the role
        #
        # @return [Permission] assigned permissions
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_permissions
            return Permission.list_for_role(role_id)
        end

        # Assign a permission to a role
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to the role.
        #
        # @return [Permission] assigned permission
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_permission(permission_id)
            return Permission.assign_to_role(role_id, permission_id)
        end

        # Remove a permission from a role
        #
        # @param permission_id [String] The permission_id of the permission you want to remove from the role.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_permission(permission_id)
            return Permission.remove_from_role(role_id, permission_id)
        end
    end
end
