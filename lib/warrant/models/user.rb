# frozen_string_literal: true

module Warrant
    class User < Warrant::Object
        OBJECT_TYPE = "user"

        include Warrant::WarrantObject

        alias :user_id :object_id

        # @!visibility private
        def initialize(user_id, meta = {}, created_at = nil)
            super(OBJECT_TYPE, user_id, meta, created_at)
        end

        # Creates a user with the given parameters
        #
        # @option params [String] :user_id User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        # @option params [Hash] :meta A JSON object containing additional information about this user (e.g. email/name) to be persisted to Warrant. (optional)
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
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.create(params = {}, options = {})
            object = Object.create({ object_type: OBJECT_TYPE, object_id: params[:user_id], meta: params[:meta] }, options)
            return User.new(object.object_id, object.meta, object.created_at)
        end

        # Batch creates multiple users with given parameters
        #
        # @param [Array<Hash>] users Array of users to create.
        # @option users [String] :user_id User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        # @option users [Hash] :meta A JSON object containing additional information about the user (e.g. name/description, etc.) to be persisted to Warrant. (optional)
        #
        # @return [Array<User>] all created users
        #
        # @example Create two new users with user ids "test-user-1" and "test-user-2"
        #   Warrant::User.batch_create([{ user_id: "test-user-1" }, { user_id: "test-user-2" }])
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.batch_create(users, options = {})
            res = Object.batch_create(users.map{ |user| { object_type: OBJECT_TYPE, object_id: user[:user_id], meta: user[:meta] }}, options)
            return res.map{ |obj| User.new(obj.object_id, obj.meta, obj.created_at)}
        end

        # Deletes a user with given user id
        #
        # @param user_id [String] User defined string identifier for this user.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a User with the user id "test-customer"
        #   Warrant::User.delete("test-customer")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.delete(user_id, options = {})
            return Object.delete(OBJECT_TYPE, user_id, options)
        end

        # Batch deletes multiple users with given parameters
        #
        # @param [Array<Hash, User>] users Array of users to delete.
        # @option users [String] :user_id Customer defined string identifier for this user.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete two users with ids "test-user-1" and "test-user-2"
        #   Warrant::User.batch_delete([{ user_id: "test-user-1" }, { user_id: "test-user-2" }])
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.batch_delete(users, options = {})
            return Object.batch_delete(users.map{ |user|
                if user.instance_of? User
                    { object_type: OBJECT_TYPE, object_id: user.object_id }
                else
                    { object_type: OBJECT_TYPE, object_id: user[:user_id] }
                end
            }, options)
        end

        # Lists all users for your organization
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
        # @return [Array<User>] all users for your organization
        #
        # @example List all users
        #   Warrant::User.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {}, options = {})
            filters.merge({ object_type: "user" })
            list_response = Object.list(filters, options)
            users = list_response.results.map{ |object| User.new(object.object_id, object.meta, object.created_at)}
            return ListResponse.new(users, list_response.prev_cursor, list_response.next_cursor)
        end

        # Get a user with the given user_id
        #
        # @param user_id [String] User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        #
        # @return [User] retrieved user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.get(user_id, options = {})
            object = Object.get(OBJECT_TYPE, user_id, options)
            return User.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a user with the given user_id
        #
        # @param user_id [String] User defined string identifier for this user.
        # @param meta [Hash] A JSON object containing additional information about this user (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [User] updated user
        #
        # @example Update user "test-user"'s email
        #   Warrant::User.update("test-user", { email: "my-new-email@example.com" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.update(user_id, meta, options = {})
            object = Object.update(OBJECT_TYPE, user_id, meta, options)
            return User.new(object.object_id, object.meta, object.created_at)
        end

        # Updates the user with the given params
        #
        # @param meta [Hash] A JSON object containing additional information about this user (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [User] updated user
        #
        # @example Update user "test-user"'s email
        #   user = Warrant::User.get("test-user")
        #   user.update({ email: "my-new-email@example.com" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(meta, options = {})
            return User.update(user_id, meta, options)
        end

        # List all roles for a user.
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
        # @return [Array<Role>] all roles for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_roles(filters = {}, options = {})
            return Role.list_for_user(user_id, filters, options)
        end

        # Assign a role to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a role to.
        # @param role_id [String] The role_id of the role you want to assign to a user.
        # @param relation [String] The relation for this role to user association. The relation must be valid as per the +role+ object type definition.
        #
        # @return [Permission] assigned role
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.assign_role("admin")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_role(role_id, relation: "member", options: {})
            return Role.assign_to_user(user_id, role_id, relation: relation, options: options)
        end

        # Remove a role from a user
        #
        # @param user_id [String] The user_id of the role you want to assign a role to.
        # @param role_id [String] The role_id of the role you want to assign to a user.
        # @param relation [String] The relation for this role to user association. The relation must be valid as per the +role+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.remove_role("admin")
        #
        # @raise [Warrant::ForbiddenError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def remove_role(role_id, relation: "member", options: {})
            return Role.remove_from_user(user_id, role_id, relation: relation, options: options)
        end

        # List all permissions for a user
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
        # @return [Array<Permission>] all permissions for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_permissions(filters = {}, options = {})
            return Permission.list_for_user(user_id, filters, options)
        end

        # Assign a permission to a user
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to a user.
        # @param relation [String] The relation for this permission to user association. The relation must be valid as per the +permission+ object type definition.
        #
        # @return [Permission] assigned permission
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.assign_permission("edit-report")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_permission(permission_id, relation: "member", options: {})
            return Permission.assign_to_user(user_id, permission_id, relation: relation, options: options)
        end

        # Remove a permission from a user
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to a user.
        # @param relation [String] The relation for this permission to user association. The relation must be valid as per the +permission+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.remove_permission("edit-report")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def remove_permission(permission_id, relation: "member", options: {})
            Permission.remove_from_user(user_id, permission_id, relation: relation, options: options)
        end

        # Checks whether a user has a given permission
        #
        # @param permission_id [String] The permission_id of the permission you want to check whether or not it exists on the user.
        # @param relation [String] The relation for this permission to user association. The relation must be valid as per the +permission+ object type definition.
        # @option options [Hash] :context Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @option options [Boolean] :debug Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the user has the given permission
        #
        # @example
        #   user = Warrant::User.get("fawa324nfa")
        #   user.has_permission?("edit-report")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def has_permission?(permission_id, relation: "member", options: {})
            return Warrant.user_has_permission?({
                permission_id: permission_id,
                relation: relation,
                user_id: user_id,
                context: options[:context],
                debug: options[:debug]
            }, options)
        end

        # List all users for a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant from which to fetch users
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
        # @return [Array<User>] all users for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_tenant(tenant_id, filters = {}, options = {})
            query_response = Warrant.query("select * of type user for tenant:#{tenant_id}", filters: filters, options: options)
            users = query_response.results.map{ |result| User.new(result.object_id, result.meta) }
            return ListResponse.new(users, query_response.prev_cursor, query_response.next_cursor)
        end

        # Add a user to a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to assign a user to.
        # @param user_id [String] The user_id of the user you want to add to the tenant.
        # @param relation [String] The relation for this tenant to user association. The relation must be valid as per the +tenant+ object type definition.
        #
        # @return [Warrant] warrant assigning user to the tenant
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_tenant(tenant_id, user_id, relation: "member", options: {})
            Warrant.create({ object_type: Tenant::OBJECT_TYPE, object_id: tenant_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # Remove a user from a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to remove the user from.
        # @param user_id [String] The user_id of the user you want to remove from the tenant.
        # @param relation [String] The relation for this tenant to user association. The relation must be valid as per the +tenant+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_tenant(tenant_id, user_id, relation: "member", options: {})
            Warrant.delete({ object_type: Tenant::OBJECT_TYPE, object_id: tenant_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # List all tenants for a user
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
        # @return [Array<Tenant>] all tenants for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def list_tenants(filters = {}, options = {})
            return Tenant.list_for_user(user_id, filters, options)
        end

        # List pricing tiers for a user
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
        # @return [Array<PricingTier>] assigned pricing tiers for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_pricing_tiers(filters = {}, options = {})
            return PricingTier.list_for_user(user_id, filters, options)
        end

        # Assign a pricing tier to a user
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign to the user.
        # @param relation [String] The relation for this pricing tier to user association. The relation must be valid as per the +pricing tier+ object type definition.
        #
        # @return [PricingTier] assigned pricing tier
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_pricing_tier(pricing_tier_id, relation: "member", options: {})
            return PricingTier.assign_to_user(user_id, pricing_tier_id, relation: relation, options: options)
        end

        # Remove a pricing tier from a user
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign from the user.
        # @param relation [String] The relation for this pricing tier to user association. The relation must be valid as per the +pricing tier+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_pricing_tier(pricing_tier_id, relation: "member", options: {})
            return PricingTier.remove_from_user(user_id, pricing_tier_id, relation: relation, options: options)
        end

        # List features for a user
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
        # @return [Array<Feature>] assigned features for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_features(filters = {}, options = {})
            return Feature.list_for_user(user_id, filters, options)
        end

        # Assign a feature to a user
        #
        # @param feature_id [String] The feature_id of the feature you want to assign to the user.
        # @param relation [String] The relation for this feature to user association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [Feature] assigned feature
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_feature(feature_id, relation: "member", options: {})
            return Feature.assign_to_user(user_id, feature_id, relation: relation, options: options)
        end

        # Remove a feature from a user
        #
        # @param feature_id [String] The feature_id of the feature you want to assign from the user.
        # @param relation [String] The relation for this feature to user association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_feature(feature_id, relation: "member", options: {})
            return Feature.remove_from_user(user_id, feature_id, relation: relation, options: options)
        end

        # Check whether a user has a given feature
        #
        # @param feature_id [String] The feature_id of the feature to check whether the user has access to.
        # @param relation [String] The relation for this feature to user association. The relation must be valid as per the +feature+ object type definition.
        # @option options [Hash] :context Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @option options [Boolean] :debug Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the user has the given feature
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def has_feature?(feature_id, relation: "member", options: {})
            return Warrant.has_feature?({
                feature_id: feature_id,
                relation: relation,
                subject: {
                    object_type: "user",
                    object_id: user_id
                },
                context: options[:context],
                debug: options[:debug]
            }, options)
        end

        def warrant_object_type
            "user"
        end

        def warrant_object_id
            user_id
        end
    end
end
