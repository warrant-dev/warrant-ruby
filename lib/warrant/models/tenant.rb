# frozen_string_literal: true

module Warrant
    class Tenant < Warrant::Object
        OBJECT_TYPE = "tenant"

        include Warrant::WarrantObject

        alias :tenant_id :object_id

        # @!visibility private
        def initialize(tenant_id, meta = {}, created_at = nil)
            super(OBJECT_TYPE, tenant_id, meta, created_at)
        end

        # Creates a tenant with the given parameters
        #
        # @option params [String] :tenant_id User defined string identifier for this tenant. If not provided, Warrant will create an id for the tenant and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        # @option params [Hash] :meta A JSON object containing additional information about this tenant (e.g. name/description, etc.) to be persisted to Warrant. (optional)
        #
        # @return [Tenant] created tenant
        #
        # @example Create a new Tenant with the tenant id "test-customer"
        #   Warrant::Tenant.create(tenant_id: "test-customer")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.create(params = {}, options = {})
            object = Object.create({ object_type: OBJECT_TYPE, object_id: params[:tenant_id], meta: params[:meta] }, options)
            return Tenant.new(object.object_id, object.meta, object.created_at)
        end

        # Batch creates multiple tenants with given parameters
        #
        # @param [Array<Hash>] tenants Array of tenants to create.
        # @option tenants [String] :tenant_id User defined string identifier for this tenant. If not provided, Warrant will create an id for the tenant and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        # @option tenants [Hash] :meta A JSON object containing additional information about the tenant (e.g. name/description, etc.) to be persisted to Warrant. (optional)
        #
        # @return [Array<Tenant>] all created tenants
        #
        # @example Create two new tenants with tenant ids "test-tenant-1" and "test-tenant-2"
        #   Warrant::Tenant.batch_create([{ tenant_id: "test-tenant-1" }, { tenant_id: "test-tenant-2" }])
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.batch_create(tenants, options = {})
            res = Object.batch_create(tenants.map{ |tenant| { object_type: OBJECT_TYPE, object_id: tenant[:tenant_id], meta: tenant[:meta] }}, options)
            return res.map{ |obj| Tenant.new(obj.object_id, obj.meta, obj.created_at)}
        end

        # Deletes a tenant with given tenant id
        #
        # @param tenant_id [String] User defined string identifier for this tenant.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a Tenant with the tenant id "test-customer"
        #   Warrant::Tenant.delete("test-customer")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.delete(tenant_id, options = {})
            return Object.delete(OBJECT_TYPE, tenant_id, options)
        end

        # Batch deletes multiple tenants with given parameters
        #
        # @param [Array<Hash, Tenant>] tenants Array of tenants to delete.
        # @option tenants [String] :tenant_id Customer defined string identifier for this tenant.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete two tenants with ids "test-tenant-1" and "test-tenant-2"
        #   Warrant::Tenant.batch_delete([{ tenant_id: "test-tenant-1" }, { tenant_id: "test-tenant-2" }])
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.batch_delete(tenants, options = {})
            return Object.batch_delete(tenants.map{ |tenant|
                if tenant.instance_of? Tenant
                    { object_type: OBJECT_TYPE, object_id: tenant.object_id }
                else
                    { object_type: OBJECT_TYPE, object_id: tenant[:tenant_id] }
                end
            }, options)
        end

        # Lists all tenants for your organization
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
        # @return [Array<Tenant>] all tenants for your organization
        #
        # @example List all tenants
        #   Warrant::Tenant.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {}, options = {})
            filters.merge({ object_type: "tenant" })
            list_response = Object.list(filters, options)
            tenants = list_response.results.map{ |object| Tenant.new(object.object_id, object.meta, object.created_at)}
            return ListResponse.new(tenants, list_response.prev_cursor, list_response.next_cursor)
        end

        # Get a tenant with the given tenant_id
        #
        # @param tenant_id [String] User defined string identifier for this tenant. If not provided, Warrant will create an id for the tenant and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        #
        # @return [Tenant] retrieved tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.get(tenant_id, options = {})
            object = Object.get(OBJECT_TYPE, tenant_id, options)
            return Tenant.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a tenant with the given tenant_id
        #
        # @param tenant_id [String] User defined string identifier for this tenant.
        # @param meta [Hash] A JSON object containing additional information about this tenant (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [Tenant] updated tenant
        #
        # @example Update tenant "test-tenant"'s email
        #   Warrant::Tenant.update("test-tenant", { email: "my-new-email@example.com" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.update(tenant_id, meta, options = {})
            object = Object.update(OBJECT_TYPE, tenant_id, meta, options)
            return Tenant.new(object.object_id, object.meta, object.created_at)
        end

        # Updates the tenant with the given params
        #
        # @param meta [Hash] A JSON object containing additional information about this tenant (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [Tenant] updated tenant
        #
        # @example Update tenant "test-tenant"'s name
        #   tenant = Warrant::Tenant.get("test-tenant")
        #   tenant.update({ name: "my-new-name@example.com" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(meta, options = {})
            return Tenant.update(tenant_id, meta, options)
        end

        # Add a user to a tenant
        #
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
        def assign_user(user_id, relation: "member", options: {})
            return User.assign_to_tenant(tenant_id, user_id, relation: relation, options: options)
        end

        # Remove a user from a tenant
        #
        # @param user_id [String] The user_id of the user you want to remove from the tenant.
        # @param relation [String] The relation for this tenant to user association. The relation must be valid as per the +tenant+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_user(user_id, relation: "member", options: {})
            return User.remove_from_tenant(tenant_id, user_id, relation: relation, options: options)
        end

        # List all tenants for a user
        #
        # @param user_id [String] The user_id of the user from which to fetch tenants
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
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_user(user_id, filters = {}, options = {})
            query_response = Warrant.query("select tenant where user:#{user_id} is *", filters: filters, options: options)
            tenants = query_response.results.map{ |result| Tenant.new(result.object_id, result.meta) }
            return ListResponse.new(tenants, query_response.prev_cursor, query_response.next_cursor)
        end

        # List all users for a tenant
        #
        # @return [Array<User>] all users for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def list_users(filters = {}, options = {})
            return User.list_for_tenant(tenant_id, filters, options)
        end

        # List pricing tiers for a tenant
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
        # @return [Array<Feature>] assigned pricing tiers for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_pricing_tiers(filters = {}, options = {})
            return PricingTier.list_for_tenant(tenant_id, filters, options)
        end

        # Assign a pricing tier to a tenant
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign to the tenant.
        # @param relation [String] The relation for this pricing tier to tenant association. The relation must be valid as per the +pricing tier+ object type definition.
        #
        # @return [PricingTier] assigned pricing tier
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_pricing_tier(pricing_tier_id, relation: "member", options: {})
            return PricingTier.assign_to_tenant(tenant_id, pricing_tier_id, relation: relation, options: options)
        end

        # Remove a pricing_tier from a tenant
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing_tier you want to remove from the tenant.
        # @param relation [String] The relation for this pricing tier to tenant association. The relation must be valid as per the +pricing tier+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_pricing_tier(pricing_tier_id, relation: "member", options: {})
            return PricingTier.remove_from_tenant(tenant_id, pricing_tier_id, relation: relation, options: options)
        end

        # List features for a tenant
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
        # @return [Array<Feature>] assigned features for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_features(filters = {}, options = {})
            return Feature.list_for_tenant(tenant_id, filters, options)
        end

        # Assign a feature to a tenant
        #
        # @param feature_id [String] The feature_id of the feature you want to assign to the tenant.
        # @param relation [String] The relation for this feature to tenant association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [Feature] assigned feature
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_feature(feature_id, relation: "member", options: {})
            return Feature.assign_to_tenant(tenant_id, feature_id, relation: relation, options: options)
        end

        # Remove a feature from a tenant
        #
        # @param feature_id [String] The feature_id of the feature you want to remove from the tenant.
        # @param relation [String] The relation for this feature to tenant association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_feature(feature_id, relation: "member", options: {})
            return Feature.remove_from_tenant(tenant_id, feature_id, relation: relation, options: options)
        end

        # Check whether a tenant has a given feature
        #
        # @param feature_id [String] The feature_id of the feature to check whether the tenant has access to.
        # @param relation [String] The relation for this feature to tenant association. The relation must be valid as per the +feature+ object type definition.
        # @option options [Hash] :context Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @option options [Boolean] :debug Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the tenant has the given feature
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
                    object_type: "tenant",
                    object_id: tenant_id
                },
                context: options[:context],
                debug: options[:debug]
            }, options)
        end

        def warrant_object_type
            "tenant"
        end

        def warrant_object_id
            tenant_id
        end
    end
end
