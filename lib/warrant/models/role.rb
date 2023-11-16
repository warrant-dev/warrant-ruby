# frozen_string_literal: true

module Warrant
    class Role < Warrant::Object
        OBJECT_TYPE = "role"

        include Warrant::WarrantObject

        alias :role_id :object_id

        # @!visibility private
        def initialize(role_id, meta = {}, created_at = nil)
            super(OBJECT_TYPE, role_id, meta, created_at)
        end

        # Creates a role with the given parameters
        #
        # @option params [String] :role_id User defined string identifier for this role. If not provided, Warrant will create an id for the role and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that role. Note that roleIds in Warrant must be composed of alphanumeric chars, '-', and/or '_'. (optional)
        # @option params [Hash] :meta A JSON object containing additional information about this role (e.g. name/description) to be persisted to Warrant. (optional)
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
        def self.create(params = {}, options = {})
            object = Object.create({ object_type: OBJECT_TYPE, object_id: params[:role_id], meta: params[:meta] }, options)
            return Role.new(object.object_id, object.meta, object.created_at)
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
        def self.delete(role_id, options = {})
            return Object.delete(OBJECT_TYPE, role_id, options)
        end

        # Lists all roles for your organization
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
        # @return [Array<Role>] all roles for your organization
        #
        # @example List all roles
        #   Warrant::Role.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {}, options = {})
            filters.merge({ object_type: "role" })
            list_response = Object.list(filters, options)
            roles = list_response.results.map{ |object| Role.new(object.object_id, object.meta, object.created_at)}
            return ListResponse.new(roles, list_response.prev_cursor, list_response.next_cursor)
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
        def self.get(role_id, options = {})
            object = Object.get(OBJECT_TYPE, role_id, options)
            return Role.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a role with the given role_id and params
        #
        # @param role_id [String] The role_id of the role to be updated.
        # @param meta [Hash] A JSON object containing additional information about this role (e.g. name/description, etc.) to be persisted to Warrant.
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
        def self.update(role_id, meta, options = {})
            object = Object.update(OBJECT_TYPE, role_id, meta, options)
            return Role.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a role with the given params
        #
        # @param meta [Hash] A JSON object containing additional information about this role (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [Role] updated role
        #
        # @example Update role "test-role"'s name
        #   role = Warrant::Role.get("test-role")
        #   role.update({ name: "Test Role" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(meta, options = {})
            return Role.update(role_id, meta)
        end

        # List roles for user
        #
        # @param user_id [String] The user_id of the user you want to retrieve roles for.
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
        # @return [Array<Role>] all assigned roles for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_user(user_id, filters = {}, options = {})
            query_response = Warrant.query("select role where user:#{user_id} is *", filters: filters, options: options)
            roles = query_response.results.map{ |result| Role.new(result.object_id, result.meta) }
            return ListResponse.new(roles, query_response.prev_cursor, query_response.next_cursor)
        end

        # Assign a role to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a role to.
        # @param role_id [String] The role_id of the role you want to assign to a user.
        # @param relation [String] The relation for this role to user association. The relation must be valid as per the +role+ object type definition.
        #
        # @return [Warrant] warrant assigning role to user
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_user(user_id, role_id, relation: "member", options: {})
            Warrant.create({ object_type: Role::OBJECT_TYPE, object_id: role_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # Remove a role from a user
        #
        # @param user_id [String] The user_id of the role you want to remove a role from.
        # @param role_id [String] The role_id of the role you want to remove from a user.
        # @param relation [String] The relation for this role to user association. The relation must be valid as per the +role+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::ForbiddenError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_user(user_id, role_id, relation: "member", options: {})
            Warrant.delete({ object_type: Role::OBJECT_TYPE, object_id: role_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # List assigned permissions for the role
        #
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
        # @return [Permission] assigned permissions
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_permissions(filters = {}, options = {})
            return Permission.list_for_role(role_id, filters, options)
        end

        # Assign a permission to a role
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to the role.
        # @param relation [String] The relation for this permission to user association. The relation must be valid as per the +permission+ object type definition.
        #
        # @return [Permission] assigned permission
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_permission(permission_id, relation: "member", options: {})
            return Permission.assign_to_role(role_id, permission_id, relation: relation, options: options)
        end

        # Remove a permission from a role
        #
        # @param permission_id [String] The permission_id of the permission you want to remove from the role.
        # @param relation [String] The relation for this permission to user association. The relation must be valid as per the +permission+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_permission(permission_id, relation: "member", options: {})
            return Permission.remove_from_role(role_id, permission_id, relation: relation, options: options)
        end

        def warrant_object_type
            "role"
        end

        def warrant_object_id
            role_id
        end
    end
end
