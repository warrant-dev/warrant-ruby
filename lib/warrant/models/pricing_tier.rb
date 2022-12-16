# frozen_string_literal: true

module Warrant
    class PricingTier
        attr_reader :pricing_tier_id

        # @!visibility private
        def initialize(pricing_tier_id)
            @pricing_tier_id = pricing_tier_id
        end

        # Creates a pricing tier with the given parameters
        #
        # @option params [String] :pricing_tier_id A string identifier for this new pricing tier. The pricing_tier_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'.
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
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/pricing-tiers"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                PricingTier.new(res_json['pricingTierId'])
            else
                APIOperations.raise_error(res)
            end
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
        def self.delete(pricing_tier_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/pricing-tiers/#{pricing_tier_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Lists all pricing tiers for your organization
        #
        # @return [Array<Feature>] all pricing tiers for your organization
        #
        # @example List all pricing tiers
        #   Warrant::PricingTier.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/pricing-tiers"))

            case res
            when Net::HTTPSuccess
                pricing_tiers = JSON.parse(res.body)
                pricing_tiers.map{ |pricing_tier| PricingTier.new(pricing_tier['pricingTierId']) }
            else
                APIOperations.raise_error(res)
            end
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
        def self.get(pricing_tier_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/pricing-tiers/#{pricing_tier_id}"))

            case res
            when Net::HTTPSuccess
                pricing_tier = JSON.parse(res.body)
                PricingTier.new(pricing_tier['pricingTierId'])
            else
                APIOperations.raise_error(res)
            end
        end


        # List pricing tiers for tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant to list pricing tiers for.
        #
        # @return [Array<PricingTier>] assigned pricing tiers for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_tenant(tenant_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/pricing-tiers"))

            case res
            when Net::HTTPSuccess
                pricing_tiers = JSON.parse(res.body)
                pricing_tiers.map{ |pricing_tier| PricingTier.new(pricing_tier['pricingTierId']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Assign a pricing tier to a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to assign a pricing tier to.
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign to a tenant.
        #
        # @return [PricingTier] assigned pricing tier
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_tenant(tenant_id, pricing_tier_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/pricing-tiers/#{pricing_tier_id}"))

            case res
            when Net::HTTPSuccess
                pricing_tier = JSON.parse(res.body)
                PricingTier.new(pricing_tier['pricingTierId'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Remove a pricing tier from a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to remove a pricing tier from.
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to remove from a tenant.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_tenant(tenant_id, pricing_tier_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/pricing-tiers/#{pricing_tier_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # List pricing tiers for user
        #
        # @param user_id [String] The user_id of the user to list pricing tiers for.
        #
        # @return [Array<PricingTier>] assigned pricing tiers for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_user(user_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/pricing-tiers"))

            case res
            when Net::HTTPSuccess
                pricing_tiers = JSON.parse(res.body)
                pricing_tiers.map{ |pricing_tier| PricingTier.new(pricing_tier['pricingTierId']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Assign a pricing tier to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a pricing tier to.
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign to a user.
        #
        # @return [PricingTier] assigned pricing tier
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_user(user_id, pricing_tier_id)
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/pricing-tiers/#{pricing_tier_id}"))

            case res
            when Net::HTTPSuccess
                pricing_tier = JSON.parse(res.body)
                PricingTier.new(pricing_tier['pricingTierId'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Remove a pricing tier from a user
        #
        # @param user_id [String] The user_id of the user you want to remove a pricing tier from.
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to remove from a user.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_user(user_id, pricing_tier_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/pricing-tiers/#{pricing_tier_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # List features for a pricing tier
        #
        # @return [Array<Feature>] assigned features for the pricing tier
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_features
            return Feature.list_for_pricing_tier(pricing_tier_id)
        end

        # Assign a feature to a pricing tier
        #
        # @param feature_id [String] The feature_id of the feature you want to assign to the pricing tier.
        #
        # @return [Feature] assigned feature
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_feature(feature_id)
            return Feature.assign_to_pricing_tier(pricing_tier_id, feature_id)
        end

        # Remove a feature from a pricing tier
        #
        # @param feature_id [String] The feature_id of the feature you want to assign from the pricing tier.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_feature(feature_id)
            return Feature.remove_from_pricing_tier(pricing_tier_id, feature_id)
        end

        # Check whether a pricing tier has a given feature
        #
        # @param feature_id [String] The feature_id of the feature to check whether the pricing tier has access to.
        #
        # @return [Boolean] whether or not the pricing tier has the given feature
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def has_feature?(feature_id, opts = {})
            return Warrant.has_feature?(
                feature_id: feature_id,
                subject: {
                    object_type: "pricing-tier",
                    object_id: pricing_tier_id
                },
                consistent_read: opts[:consistent_read],
                debug: opts[:debug]
            )
        end
    end
end
