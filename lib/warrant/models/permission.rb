# frozen_string_literal: true

module Warrant
    class Permission < Warrant::Object
        OBJECT_TYPE = "permission"

        include Warrant::WarrantObject

        alias :permission_id :object_id

        # @!visibility private
        def initialize(permission_id, meta = {}, created_at = nil)
            super(OBJECT_TYPE, permission_id, meta, created_at)
        end

        # Creates a permission with the given parameters
        #
        # @option params [String] :role_id User defined string identifier for this permission. If not provided, Warrant will create an id for the permission and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that permission. Note that permissionIds in Warrant must be composed of alphanumeric chars, '-', and/or '_'. (optional)
        # @option params [Hash] :meta A JSON object containing additional information about this permission (e.g. name/description) to be persisted to Warrant. (optional)
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
        def self.create(params = {}, options = {})
            object = Object.create({ object_type: OBJECT_TYPE, object_id: params[:permission_id], meta: params[:meta] }, options)
            return Permission.new(object.object_id, object.meta, object.created_at)
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
        def self.delete(permission_id, options = {})
            return Object.delete(OBJECT_TYPE, permission_id, options)
        end

        # Lists all permissions for your organization
        #
        # @param [Hash] filters Filters to apply to result set
        # @param [Hash] options Options to apply on a per-request basis
        # @option filters [Integer] :limit A positive integer representing the maximum number of items to return in the response. Must be less than or equal to 1000. Defaults to 25. (optional)
        # @option filters [String] :prev_cursor A cursor representing your place in a list of results. Requests containing prev_cursor will return the results immediately preceding the cursor. (optional)
        # @option filters [String] :next_cursor A cursor representing your place in a list of results. Requests containing next_cursor will return the results immediately following the cursor. (optional)
        # @option filters [String] :sort_by The column to sort the result by. Unless otherwise specified, all list endpoints are sorted by their unique identifier by default. Supported values for objects are +object_type+, +object_id+, and +created_at+ (optional)
        # @option filters [String] :sort_order The order in which to sort the result by. Valid values are +ASC+ and +DESC+. Defaults to +ASC+. (optional)
        # @option options [String] :warrant_token A valid warrant token from a previous write operation or latest. Used to specify desired consistency for this read operation. (optional)
        #
        # @return [Array<Permission>] all permissions for your organization
        #
        # @example List all permissions
        #   Warrant::Permission.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {}, options = {})
            filters.merge({ object_type: "permission" })
            list_response = Object.list(filters, options)
            permissions = list_response.results.map{ |object| Permission.new(object.object_id, object.meta, object.created_at)}
            return ListResponse.new(permissions, list_response.prev_cursor, list_response.next_cursor)
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
        def self.get(permission_id, options = {})
            object = Object.get(OBJECT_TYPE, permission_id, options)
            return Permission.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a permission with the given role_id and params
        #
        # @param permission_id [String] The permission_id of the permission to be updated.
        # @param meta [Hash] A JSON object containing additional information about this permission (e.g. name/description, etc.) to be persisted to Warrant.
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
        def self.update(permission_id, meta, options = {})
            object = Object.update(OBJECT_TYPE, permission_id, meta, options)
            return Permission.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a permission with the given params
        #
        # @param [Hash] params attributes to update user with
        # @param meta [Hash] A JSON object containing additional information about this permission (e.g. name/description, etc.) to be persisted to Warrant.
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
        def update(meta, options = {})
            return Permission.update(permission_id, meta, options)
        end

        # List permissions for a role
        #
        # @param role_id [String] The role_id of the role to list assigned permissions for.
        # @param [Hash] filters Filters to apply to result set
        # @param [Hash] options Options to apply on a per-request basis
        # @option filters [String] :object_type Only return objects with an `objectType` matching this value
        # @option filters [Integer] :limit A positive integer representing the maximum number of items to return in the response. Must be less than or equal to 1000. Defaults to 25. (optional)
        # @option filters [String] :prev_cursor A cursor representing your place in a list of results. Requests containing prev_cursor will return the results immediately preceding the cursor. (optional)
        # @option filters [String] :next_cursor A cursor representing your place in a list of results. Requests containing next_cursor will return the results immediately following the cursor. (optional)
        # @option filters [String] :sort_by The column to sort the result by. Unless otherwise specified, all list endpoints are sorted by their unique identifier by default. Supported values for objects are +object_type+, +object_id+, and +created_at+ (optional)
        # @option filters [String] :sort_order The order in which to sort the result by. Valid values are +ASC+ and +DESC+. Defaults to +ASC+. (optional)
        # @option options [String] :warrant_token A valid warrant token from a previous write operation or latest. Used to specify desired consistency for this read operation. (optional)
        #
        # @return [Array<Permission>] all assigned permissions for the role
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_role(role_id, filters = {}, options = {})
            query_response = Warrant.query("select permission where role:#{role_id} is *", filters: filters, options: options)
            permissions = query_response.results.map{ |result| Permission.new(result.object_id, result.meta) }
            return ListResponse.new(permissions, query_response.prev_cursor, query_response.next_cursor)
        end

        # Assign a permission to a role
        #
        # @param role_id [String] The role_id of the role you want to assign a permission to.
        # @param permission_id [String] The permission_id of the permission you want to assign to a role.
        # @param relation [String] The relation for this permission to role association. The relation must be valid as per the +permission+ object type definition.
        #
        # @return [Warrant] warrant assigning permission to role
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_role(role_id, permission_id, relation: "member", options: {})
            Warrant.create({ object_type: Permission::OBJECT_TYPE, object_id: permission_id }, relation, { object_type: Role::OBJECT_TYPE, object_id: role_id }, nil, options)
        end

        # Remove a permission from a role
        #
        # @param role_id [String] The role_id of the role you want to remove a permission from.
        # @param permission_id [String] The permission_id of the permission you want to remove from a role.
        # @param relation [String] The relation for this permission to role association. The relation must be valid as per the +permission+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_role(role_id, permission_id, relation: "member", options: {})
            Warrant.delete({ object_type: Permission::OBJECT_TYPE, object_id: permission_id }, relation, { object_type: Role::OBJECT_TYPE, object_id: role_id }, nil, options)
        end

        # List permissions for a user
        #
        # @param user_id [String] The user_id of the user to list assigned permissions for.
        # @param [Hash] filters Filters to apply to result set
        # @param [Hash] options Options to apply on a per-request basis
        # @option filters [String] :object_type Only return objects with an `objectType` matching this value
        # @option filters [Integer] :limit A positive integer representing the maximum number of items to return in the response. Must be less than or equal to 1000. Defaults to 25. (optional)
        # @option filters [String] :prev_cursor A cursor representing your place in a list of results. Requests containing prev_cursor will return the results immediately preceding the cursor. (optional)
        # @option filters [String] :next_cursor A cursor representing your place in a list of results. Requests containing next_cursor will return the results immediately following the cursor. (optional)
        # @option filters [String] :sort_by The column to sort the result by. Unless otherwise specified, all list endpoints are sorted by their unique identifier by default. Supported values for objects are +object_type+, +object_id+, and +created_at+ (optional)
        # @option filters [String] :sort_order The order in which to sort the result by. Valid values are +ASC+ and +DESC+. Defaults to +ASC+. (optional)
        # @option options [String] :warrant_token A valid warrant token from a previous write operation or latest. Used to specify desired consistency for this read operation. (optional)
        #
        # @return [Array<Permission>] all assigned permissions for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_user(user_id, filters = {}, options = {})
            query_response = Warrant.query("select permission where user:#{user_id} is *", filters: filters, options: options)
            permissions = query_response.results.map{ |result| Permission.new(result.object_id, result.meta) }
            return ListResponse.new(permissions, query_response.prev_cursor, query_response.next_cursor)
        end

        # Assign a permission to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a permission to.
        # @param permission_id [String] The permission_id of the permission you want to assign to a user.
        # @param relation [String] The relation for this permission to user association. The relation must be valid as per the +permission+ object type definition.
        #
        # @return [Warrant] warrant assigning permission to user
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_user(user_id, permission_id, relation: "member", options: {})
            Warrant.create({ object_type: Permission::OBJECT_TYPE, object_id: permission_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # Remove a permission from a user
        #
        # @param user_id [String] The user_id of the user you want to remove a permission from.
        # @param permission_id [String] The permission_id of the permission you want to remove from a user.
        # @param relation [String] The relation for this permission to user association. The relation must be valid as per the +permission+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_user(user_id, permission_id, relation: "member", options: {})
            Warrant.delete({ object_type: Permission::OBJECT_TYPE, object_id: permission_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        def warrant_object_type
            "permission"
        end

        def warrant_object_id
            permission_id
        end
    end
end
