# frozen_string_literal: true

module Warrant
    class Feature < Warrant::Object
        OBJECT_TYPE = "feature"

        include Warrant::WarrantObject

        alias :feature_id :object_id

        # @!visibility private
        def initialize(feature_id, meta = {}, created_at = nil)
            super(OBJECT_TYPE, feature_id, meta, created_at)
        end

        # Creates a feature with the given parameters
        #
        # @option params [String] :feature_id User defined string identifier for this feature. If not provided, Warrant will create an id for the feature and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that feature. Note that featureIds in Warrant must be composed of alphanumeric chars, '-', and/or '_'. (optional)
        # @option params [Hash] :meta A JSON object containing additional information about this feature (e.g. name/description) to be persisted to Warrant. (optional)
        #
        # @return [Feature] created feature
        #
        # @example Create a new Feature with the feature id "test-feature"
        #   Warrant::Feature.create(feature_id: "test-feature")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        def self.create(params = {}, options = {})
            object = Object.create({ object_type: OBJECT_TYPE, object_id: params[:feature_id], meta: params[:meta] }, options)
            return Feature.new(object.object_id, object.meta, object.created_at)
        end

        # Deletes a feature with given feature id
        #
        # @param feature_id [String] The feature_id of the feature to delete.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a Feature with the feature id "test-feature"
        #   Warrant::Feature.delete("test-feature")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.delete(feature_id, options = {})
            return Object.delete(OBJECT_TYPE, feature_id, options)
        end

        # Lists all features for your organization
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
        # @return [Array<Feature>] all features for your organization
        #
        # @example List all features
        #   Warrant::Feature.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {}, options = {})
            filters.merge({ object_type: OBJECT_TYPE })
            list_response = Object.list(filters, options)
            features = list_response.results.map{ |object| Feature.new(object.object_id, object.meta, object.created_at)}
            return ListResponse.new(features, list_response.prev_cursor, list_response.next_cursor)
        end

        # Get a feature with the given feature_id
        #
        # @param feature_id [String] The feature_id of the feature to retrieve.
        #
        # @return [Feature] retrieved feature
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.get(feature_id, options = {})
            object = Object.get(OBJECT_TYPE, feature_id, options)
            return Feature.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a feature with the given feature_id and params
        #
        # @param feature_id [String] The feature_id of the feature to be updated.
        # @param meta [Hash] A JSON object containing additional information about this feature (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [Feature] updated feature
        #
        # @example Update feature "test-feature"'s name
        #   Warrant::Feature.update("test-feature", { name: "Test Feature" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.update(feature_id, meta, options = {})
            object = Object.update(OBJECT_TYPE, feature_id, meta, options)
            return Feature.new(object.object_id, object.meta, object.created_at)
        end

        # Updates a feature with the given params
        #
        # @param meta [Hash] A JSON object containing additional information about this feature (e.g. name/description, etc.) to be persisted to Warrant.
        #
        # @return [Feature] updated feature
        #
        # @example Update feature "test-feature"'s name
        #   feature = Warrant::Feature.get("test-feature")
        #   feature.update({ name: "Test Feature" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(meta, options = {})
            return Feature.update(feature_id, meta)
        end

        # List features for tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant to list features for.
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
        def self.list_for_tenant(tenant_id, filters = {}, options = {})
            query_response = Warrant.query("select feature where tenant:#{tenant_id} is *", filters: filters, options: options)
            features = query_response.results.map{ |result| Feature.new(result.object_id, result.meta) }
            return ListResponse.new(features, query_response.prev_cursor, query_response.next_cursor)
        end

        # Assign a feature to a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to assign a feature to.
        # @param feature_id [String] The feature_id of the feature you want to assign to a tenant.
        # @param relation [String] The relation for this feature to tenant association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [Warrant] warrant assigning feature to tenant
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_tenant(tenant_id, feature_id, relation: "member", options: {})
            Warrant.create({ object_type: Feature::OBJECT_TYPE, object_id: feature_id }, relation, { object_type: Tenant::OBJECT_TYPE, object_id: tenant_id }, nil, options)
        end

        # Remove a feature from a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to remove a feature from.
        # @param feature_id [String] The feature_id of the feature you want to remove from a tenant.
        # @param relation [String] The relation for this feature to tenant association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_tenant(tenant_id, feature_id, relation: "member", options: {})
            Warrant.delete({ object_type: Feature::OBJECT_TYPE, object_id: feature_id }, relation, { object_type: Tenant::OBJECT_TYPE, object_id: tenant_id }, nil, options)
        end

        # List features for user
        #
        # @param user_id [String] The user_id of the user to list features for.
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
        def self.list_for_user(user_id, filters = {}, options = {})
            query_response = Warrant.query("select feature where user:#{user_id} is *", filters: filters, options: options)
            features = query_response.results.map{ |result| Feature.new(result.object_id, result.meta) }
            return ListResponse.new(features, query_response.prev_cursor, query_response.next_cursor)
        end

        # Assign a feature to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a feature to.
        # @param feature_id [String] The feature_id of the feature you want to assign to a user.
        # @param relation [String] The relation for this feature to user association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [Warrant] warrant assigning feature to user
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_user(user_id, feature_id, relation: "member", options: {})
            Warrant.create({ object_type: Feature::OBJECT_TYPE, object_id: feature_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # Remove a feature from a user
        #
        # @param user_id [String] The user_id of the user you want to remove a feature from.
        # @param feature_id [String] The feature_id of the feature you want to remove from a user.
        # @param relation [String] The relation for this feature to user association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_user(user_id, feature_id, relation: "member", options: {})
            Warrant.delete({ object_type: Feature::OBJECT_TYPE, object_id: feature_id }, relation, { object_type: User::OBJECT_TYPE, object_id: user_id }, nil, options)
        end

        # List features for pricing tier
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier to list features for.
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
        def self.list_for_pricing_tier(pricing_tier_id, filters = {}, options = {})
            query_response = Warrant.query("select feature where pricing-tier:#{pricing_tier_id} is *", filters: filters, options: options)
            features = query_response.results.map{ |result| Feature.new(result.object_id, result.meta) }
            return ListResponse.new(features, query_response.prev_cursor, query_response.next_cursor)
        end

        # Assign a feature to a pricing tier
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign a feature to.
        # @param feature_id [String] The feature_id of the feature you want to assign to a pricing tier.
        # @param relation [String] The relation for this feature to pricing tier association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [Warrant] warrant assigning feature to pricing tier
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_pricing_tier(pricing_tier_id, feature_id, relation: "member", options: {})
            Warrant.create({ object_type: Feature::OBJECT_TYPE, object_id: feature_id }, relation, { object_type: PricingTier::OBJECT_TYPE, object_id: pricing_tier_id }, nil, options)
        end

        # Remove a feature from a pricing tier
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to remove a feature from.
        # @param feature_id [String] The feature_id of the feature you want to remove from a pricing tier.
        # @param relation [String] The relation for this feature to pricing tier association. The relation must be valid as per the +feature+ object type definition.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_pricing_tier(pricing_tier_id, feature_id, relation: "member", options: {})
            Warrant.delete({ object_type: Feature::OBJECT_TYPE, object_id: feature_id }, relation, { object_type: PricingTier::OBJECT_TYPE, object_id: pricing_tier_id }, nil, options)
        end

        def warrant_object_type
            "feature"
        end

        def warrant_object_id
            feature_id
        end
    end
end
