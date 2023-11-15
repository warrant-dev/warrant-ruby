# frozen_string_literal: true

module Warrant
    class PricingTier < Warrant::Object
        OBJECT_TYPE = "pricing-tier"

        include Warrant::WarrantObject

        alias :pricing_tier_id :object_id

        # @!visibility private
        def initialize(pricing_tier_id, meta = {}, created_at = nil)
            super(OBJECT_TYPE, pricing_tier_id, meta, created_at)
        end

        # Creates a pricing tier with the given parameters
        #
        # @option params [String] :pricing tier_id User defined string identifier for this pricing tier. If not provided, Warrant will create an id for the pricing tier and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that pricing tier. Note that pricingTierIds in Warrant must be composed of alphanumeric chars, '-', and/or '_'. (optional)
        # @option params [Hash] :meta A JSON object containing additional information about this pricing tier (e.g. name/description) to be persisted to Warrant. (optional)
        #
        # @return [PricingTier] created pricing tier
        #
        # @example Create a new PricingTier with the pricing tier id "test-pricing-tier"
        #   Warrant::PricingTier.create(pricing_tier_id: "test-pricing-tier")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        def self.create(params = {}, options = {})
            object = Object.create({ object_type: OBJECT_TYPE, object_id: params[:pricing_tier_id], meta: params[:meta] }, options)
            return PricingTier.new(object.object_id, object.meta, object.created_at)
        end

        # Deletes a pricing tier with given pricing tier id
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier to delete.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a PricingTier with the pricing tier id "test-pricing-tier"
        #   Warrant::PricingTier.delete("test-pricing-tier")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.delete(pricing_tier_id, options = {})
            return Object.delete(OBJECT_TYPE, pricing_tier_id, options)
        end

        # Lists all pricing tiers for your organization
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
        # @return [Array<PricingTier>] all pricing tiers for your organization
        #
        # @example List all pricing tiers
        #   Warrant::PricingTier.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {}, options = {})
            filters.merge({ object_type: "pricing-tier" })
            list_response = Object.list(filters, options)
            pricing_tiers = list_response.results.map{ |object| PricingTier.new(object.object_id, object.meta, object.created_at)}
            return ListResponse.new(pricing_tiers, list_response.prev_cursor, list_response.next_cursor)
        end

        # Get a pricing_tier with the given pricing_tier_id
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier to retrieve.
        #
        # @return [PricingTier] retrieved pricing tier
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.get(pricing_tier_id, options = {})
            object = Object.get(OBJECT_TYPE, pricing_tier_id, options)
            return PricingTier.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a pricing tier with the given pricing_tier_id and params
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier to be updated.
        # @param meta [Hash] A JSON object containing additional information about this pricing tier (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [PricingTier] updated pricing tier
        #
        # @example Update pricing tier "test-pricing-tier"'s name
        #   Warrant::PricingTier.update("test-pricing-tier", { name: "Test Tier" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.update(pricing_tier_id, meta, options = {})
            object = Object.update(OBJECT_TYPE, pricing_tier_id, meta, options)
            return PricingTier.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a pricing tier with the given params
        #
        # @param meta [Hash] A JSON object containing additional information about this pricing tier (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [PricingTier] updated pricing tier
        #
        # @example Update pricing tier "test-pricing-tier"'s name
        #   pricing_tier = Warrant::PricingTier.get("test-pricing-tier")
        #   pricing_tier.update({ name: "Test Tier" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(meta, options = {})
            return PricingTier.update(pricing_tier_id, meta)
        end

        # List pricing tiers for tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant to list pricing tiers for.
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
        # @return [Array<PricingTier>] assigned pricing tiers for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_tenant(tenant_id, filters = {}, options = {})
            query_response = Warrant.query("select pricing-tier where tenant:#{tenant_id} is *", filters: filters, options: options)
            pricing_tiers = query_response.results.map{ |result| PricingTier.new(result.object_id, result.meta) }
            return ListResponse.new(pricing_tiers, query_response.prev_cursor, query_response.next_cursor)
        end

        # Assign a pricing tier to a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to assign a pricing tier to.
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign to a tenant.
        # @param relation [String] The relation for this pricing tier to tenant association. The relation must be valid as per the +pricing tier+ object type definition.
        #
        # @return [Warrant] warrant assigning pricing tier to tenant
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_tenant(tenant_id, pricing_tier_id, relation: "member", options: {})
            Warrant.create({ object_type: PricingTier::OBJECT_TYPE, object_id: pricing_tier_id }, relation, { object_type: Tenant::OBJECT_TYPE, object_id: tenant_id }, nil, options)
        end

        # Remove a pricing tier from a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to remove a pricing tier from.
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to remove from a tenant.
        # @param relation [String] The relation for this pricing tier to tenant association. The relation must be valid as per the +pricing tier+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_tenant(tenant_id, pricing_tier_id, relation: "member", options: {})
            Warrant.delete({ object_type: PricingTier::OBJECT_TYPE, object_id: pricing_tier_id }, relation, { object_type: Tenant::OBJECT_TYPE, object_id: tenant_id }, nil, options)
        end

        # List pricing tiers for user
        #
        # @param user_id [String] The user_id of the user to list pricing tiers for.
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
        def self.list_for_user(user_id, filters = {}, options = {})
            query_response = Warrant.query("select pricing-tier where user:#{user_id} is *", filters: filters, options: options)
            pricing_tiers = query_response.results.map{ |result| PricingTier.new(result.object_id, result.meta) }
            return ListResponse.new(pricing_tiers, query_response.prev_cursor, query_response.next_cursor)
        end

        # Assign a pricing tier to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a pricing tier to.
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign to a user.
        # @param relation [String] The relation for this pricing tier to user association. The relation must be valid as per the +pricing tier+ object type definition.
        #
        # @return [Warrant] warrant assigning pricing tier to user
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_user(user_id, pricing_tier_id, relation: "member", options: {})
            Warrant.create({ object_type: PricingTier::OBJECT_TYPE, object_id: pricing_tier_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # Remove a pricing tier from a user
        #
        # @param user_id [String] The user_id of the user you want to remove a pricing tier from.
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to remove from a user.
        # @param relation [String] The relation for this pricing tier to user association. The relation must be valid as per the +pricing tier+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_user(user_id, pricing_tier_id, relation: "member", options: {})
            Warrant.delete({ object_type: PricingTier::OBJECT_TYPE, object_id: pricing_tier_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # List features for a pricing tier
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
        # @return [Array<Feature>] assigned features for the pricing tier
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_features(filters = {}, options = {})
            return Feature.list_for_pricing_tier(pricing_tier_id, filters, options)
        end

        # Assign a feature to a pricing tier
        #
        # @param feature_id [String] The feature_id of the feature you want to assign to the pricing tier.
        # @param relation [String] The relation for this feature to pricing tier association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [Feature] assigned feature
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_feature(feature_id, relation: "member", options: {})
            return Feature.assign_to_pricing_tier(pricing_tier_id, feature_id, relation: relation, options: options)
        end

        # Remove a feature from a pricing tier
        #
        # @param feature_id [String] The feature_id of the feature you want to assign from the pricing tier.
        # @param relation [String] The relation for this feature to pricing tier association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_feature(feature_id, relation: "member", options: {})
            return Feature.remove_from_pricing_tier(pricing_tier_id, feature_id, relation: relation, options: options)
        end

        # Check whether a pricing tier has a given feature
        #
        # @param feature_id [String] The feature_id of the feature to check whether the pricing tier has access to.
        # @param relation [String] The relation for this feature to pricing tier association. The relation must be valid as per the +feature+ object type definition.
        # @param [Hash] options Options to apply on a per-request basis
        # @option options [Hash] :context Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @option options [Boolean] :debug Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the pricing tier has the given feature
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
                    object_type: "pricing-tier",
                    object_id: pricing_tier_id
                },
                context: options[:context],
                debug: options[:debug]
            }, options)
        end

        def warrant_object_type
            "pricing-tier"
        end

        def warrant_object_id
            pricing_tier_id
        end
    end
end
