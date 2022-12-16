# frozen_string_literal: true

module Warrant
    class Feature
        attr_reader :feature_id

        # @!visibility private
        def initialize(feature_id)
            @feature_id = feature_id
        end

        # Creates a feature with the given parameters
        #
        # @option params [String] :feature_id A string identifier for this new feature. The feature_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'.
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
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/features"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Feature.new(res_json['featureId'])
            else
                APIOperations.raise_error(res)
            end
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
        def self.delete(feature_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/features/#{feature_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Lists all features for your organization
        #
        # @return [Array<Feature>] all features for your organization
        #
        # @example List all features
        #   Warrant::Feature.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/features"))

            case res
            when Net::HTTPSuccess
                features = JSON.parse(res.body)
                features.map{ |feature| Feature.new(feature['featureId']) }
            else
                APIOperations.raise_error(res)
            end
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
        def self.get(feature_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/features/#{feature_id}"))

            case res
            when Net::HTTPSuccess
                feature = JSON.parse(res.body)
                Feature.new(feature['featureId'])
            else
                APIOperations.raise_error(res)
            end
        end

        # List features for tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant to list features for.
        #
        # @return [Array<Feature>] assigned features for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_tenant(tenant_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/features"))

            case res
            when Net::HTTPSuccess
                features = JSON.parse(res.body)
                features.map{ |feature| Feature.new(feature['featureId']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Assign a feature to a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to assign a feature to.
        # @param feature_id [String] The feature_id of the feature you want to assign to a tenant.
        #
        # @return [Feature] assigned feature
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_tenant(tenant_id, feature_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/features/#{feature_id}"))

            case res
            when Net::HTTPSuccess
                feature = JSON.parse(res.body)
                Feature.new(feature['featureId'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Remove a feature from a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to remove a feature from.
        # @param feature_id [String] The feature_id of the feature you want to remove from a tenant.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_tenant(tenant_id, feature_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/features/#{feature_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # List features for user
        #
        # @param user_id [String] The user_id of the user to list features for.
        #
        # @return [Array<Feature>] assigned features for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_user(user_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/features"))

            case res
            when Net::HTTPSuccess
                features = JSON.parse(res.body)
                features.map{ |feature| Feature.new(feature['featureId']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Assign a feature to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a feature to.
        # @param feature_id [String] The feature_id of the feature you want to assign to a user.
        #
        # @return [Feature] assigned feature
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_user(user_id, feature_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/features/#{feature_id}"))

            case res
            when Net::HTTPSuccess
                feature = JSON.parse(res.body)
                Feature.new(feature['featureId'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Remove a feature from a user
        #
        # @param user_id [String] The user_id of the user you want to remove a feature from.
        # @param feature_id [String] The feature_id of the feature you want to remove from a user.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_user(user_id, feature_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/features/#{feature_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # List features for pricing tier
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier to list features for.
        #
        # @return [Array<Feature>] assigned features for the pricing tier
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_pricing_tier(pricing_tier_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/pricing-tiers/#{pricing_tier_id}/features"))

            case res
            when Net::HTTPSuccess
                features = JSON.parse(res.body)
                features.map{ |feature| Feature.new(feature['featureId']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Assign a feature to a pricing tier
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign a feature to.
        # @param feature_id [String] The feature_id of the feature you want to assign to a pricing tier.
        #
        # @return [Feature] assigned pricing tier
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_pricing_tier(pricing_tier_id, feature_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/pricing-tiers/#{pricing_tier_id}/features/#{feature_id}"))

            case res
            when Net::HTTPSuccess
                feature = JSON.parse(res.body)
                Feature.new(feature['featureId'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Remove a feature from a pricing tier
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to remove a feature from.
        # @param feature_id [String] The feature_id of the feature you want to remove from a pricing tier.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_pricing_tier(pricing_tier_id, feature_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/pricing-tiers/#{pricing_tier_id}/features/#{feature_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end
    end
end
