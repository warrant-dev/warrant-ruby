# frozen_string_literal: true

module Warrant
    class Permission
        include Warrant::WarrantObject

        attr_reader :permission_id, :name, :description

        # @!visibility private
        def initialize(permission_id, name = nil, description = nil)
            @permission_id = permission_id
            @name = name
            @description = description
        end

        # Creates a permission with the given parameters
        #
        # @option params [String] :permission_id A string identifier for this new permission. The permission_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'.
        #
        # @return [Permission] created permission
        #
        # @example Create a new Permission with the permission id "test-permission"
        #   Warrant::Permission.create(permission_id: "test-permission")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/permissions"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Permission.new(res_json['permissionId'], res_json['name'], res_json['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a permission with given permission id
        #
        # @param permission_id [String] The permission_id of the permission to delete.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a Permission with the permission id "test-permission"
        #   Warrant::Permission.delete("test-permission")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.delete(permission_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/permissions/#{permission_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Lists all permissions for your organization
        #
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<Permission>] all permissions for your organization
        #
        # @example List all permissions
        #   Warrant::Permission.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/permissions"), Util.normalize_params(filters))

            case res
            when Net::HTTPSuccess
                permissions = JSON.parse(res.body)
                permissions.map{ |permission| Permission.new(permission['permissionId'], permission['name'], permission['description']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Get a permission with the given permission_id
        #
        # @param permission_id [String] The permission_id of the permission to retrieve.
        #
        # @return [Permission] retrieved permission
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.get(permission_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/permissions/#{permission_id}"))

            case res
            when Net::HTTPSuccess
                permission = JSON.parse(res.body)
                Permission.new(permission['permissionId'], permission['name'], permission['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates a permission with the given role_id and params
        #
        # @param permission_id [String] The permission_id of the permission to be updated.
        # @param [Hash] params attributes to update user with
        # @option params [String] :name Name for the permission. Designed to be used as a UI-friendly identifier. (optional)
        # @option params [String] :description Description of the permission. Designed to be used as a UI-friendly identifier. (optional)
        #
        # @return [Permission] updated permission
        #
        # @example Update permission "test-permission"'s name
        #   Warrant::Permission.update("test-permission", { name: "Test Permission" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.update(permission_id, params = {})
            res = APIOperations.put(URI.parse("#{::Warrant.config.api_base}/v1/permissions/#{permission_id}"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Permission.new(res_json['permissionId'], res_json['name'], res_json['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates a permission with the given params
        #
        # @param [Hash] params attributes to update user with
        # @option params [String] :name Name for the permission. Designed to be used as a UI-friendly identifier. (optional)
        # @option params [String] :description Description of the permission. Designed to be used as a UI-friendly identifier. (optional)
        #
        # @return [Permission] updated permission
        #
        # @example Update permission "test-permission"'s name
        #   Warrant::Permission.update("test-permission", { name: "Test Permission" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(params = {})
            return Permission.update(permission_id, params)
        end

        # List permissions for a role
        #
        # @param role_id [String] The role_id of the role to list assigned permissions for.
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<Permission>] all assigned permissions for the role
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_role(role_id, filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}/permissions"), Util.normalize_params(filters))

            case res
            when Net::HTTPSuccess
                permissions = JSON.parse(res.body)
                permissions.map{ |permission| Permission.new(permission['permissionId'], permission['name'], permission['description']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Assign a permission to a role
        #
        # @param role_id [String] The role_id of the role you want to assign a permission to.
        # @param permission_id [String] The permission_id of the permission you want to assign to a role.
        #
        # @return [Permission] assigned permission
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_role(role_id, permission_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}/permissions/#{permission_id}"))

            case res
            when Net::HTTPSuccess
                permission = JSON.parse(res.body)
                Permission.new(permission['permissionId'], permission['name'], permission['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Remove a permission from a role
        #
        # @param role_id [String] The role_id of the role you want to remove a permission from.
        # @param permission_id [String] The permission_id of the permission you want to remove from a role.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_role(role_id, permission_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/roles/#{role_id}/permissions/#{permission_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # List permissions for a user
        #
        # @param user_id [String] The user_id of the user to list assigned permissions for.
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<Permission>] all assigned permissions for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_user(user_id, filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/permissions"), Util.normalize_params(filters))

            case res
            when Net::HTTPSuccess
                permissions = JSON.parse(res.body)
                permissions.map{ |permission| Permission.new(permission['permissionId'], permission['name'], permission['description']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Assign a permission to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a permission to.
        # @param permission_id [String] The permission_id of the permission you want to assign to a user.
        #
        # @return [Permission] assigned permission
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_user(user_id, permission_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/permissions/#{permission_id}"))

            case res
            when Net::HTTPSuccess
                permission = JSON.parse(res.body)
                Permission.new(permission['permissionId'], permission['name'], permission['description'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Remove a permission from a user
        #
        # @param user_id [String] The user_id of the user you want to remove a permission from.
        # @param permission_id [String] The permission_id of the permission you want to remove from a user.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_user(user_id, permission_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/permissions/#{permission_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        def warrant_object_type
            "permission"
        end

        def warrant_object_id
            permission_id
        end
    end
end
