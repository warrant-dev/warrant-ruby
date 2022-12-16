# frozen_string_literal: true

module Warrant
    class Tenant
        attr_reader :tenant_id, :name, :created_at

        # @!visibility private
        def initialize(tenant_id, name, created_at)
            @tenant_id = tenant_id
            @name = name
            @created_at = created_at
        end

        # Creates a tenant with the given parameters
        #
        # @option params [String] :tenant_id User defined string identifier for this tenant. If not provided, Warrant will create an id for the tenant and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        # @option params [String] :name A displayable name for this tenant. (optional)
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
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/tenants"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Tenant.new(res_json['tenantId'], res_json['name'], res_json['createdAt'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Batch creates multiple tenants with given parameters
        #
        # @param [Array] Array of tenants to create.
        #   * tenant_id User defined string identifier for this tenant. If not provided, Warrant will create an id for the tenant and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        #   * name A displayable name for this tenant. (optional)
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
        def self.batch_create(tenants = [])
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/tenants"), Util.normalize_params(tenants))

            case res
            when Net::HTTPSuccess
                tenants = JSON.parse(res.body)
                tenants.map{ |tenant| Tenant.new(tenant['tenantId'], tenant['name'], tenant['createdAt']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a tenant with given tenant id
        #
        # @param tenant_id [String] User defined string identifier for this tenant. If not provided, Warrant will create an id for the tenant and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a Tenant with the tenant id "test-customer"
        #   Warrant::Tenant.delete("test-customer")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.delete(tenant_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Lists all tenants for your organization
        #
        # @return [Array<Tenant>] all tenants for your organization
        #
        # @example List all tenants
        #   Warrant::Tenant.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/tenants"))

            case res
            when Net::HTTPSuccess
                tenants = JSON.parse(res.body)
                tenants.map{ |tenant| Tenant.new(tenant['tenantId'], tenant['name'], tenant['createdAt']) }
            else
                APIOperations.raise_error(res)
            end
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
        def self.get(tenant_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}"))

            case res
            when Net::HTTPSuccess
                tenant = JSON.parse(res.body)
                Tenant.new(tenant['tenantId'], tenant['name'], tenant['createdAt'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates a tenant with the given tenant_id and params
        #
        # @param tenant_id [String] User defined string identifier for this tenant. If not provided, Warrant will create an id for the tenant and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        # @param [Hash] params attributes to update tenant with
        # @option params [String] :name A displayable name for this tenant. (optional)
        #
        # @return [Tenant] updated tenant
        #
        # @example Update tenant "test-tenant"'s name
        #   Warrant::Tenant.update("test-tenant", { name: "my-new-name@example.com" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.update(tenant_id, params = {})
            res = APIOperations.put(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                Tenant.new(res_json['tenantId'], res_json['name'], res_json['createdAt'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates the tenant with the given params
        #
        # @option params [String] :name A displayable name for this tenant. (optional)
        #
        # @return [Tenant] updated tenant
        #
        # @example Update tenant "test-tenant"'s name
        #   tenant = Warrant::Tenant.get("test-tenant")
        #   tenant.update(name: "my-new-name@example.com")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(params = {})
            return Tenant.update(tenant_id, params)
        end

        # Add a user to a tenant
        #
        # @param user_id [String] The user_id of the user you want to add to the tenant.
        #
        # @return [Warrant] warrant assigning user to the tenant
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def add_user(user_id)
            return User.add_to_tenant(tenant_id, user_id)
        end

        # Remove a user from a tenant
        #
        # @param user_id [String] The user_id of the user you want to remove from the tenant.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_user(user_id)
            return User.remove_from_tenant(tenant_id, user_id)
        end

        # List all tenants for a user
        #
        # @param user_id [String] The user_id of the user from which to fetch tenants
        #
        # @return [Array<Tenant>] all tenants for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_user(user_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}/tenants"))

            case res
            when Net::HTTPSuccess
                tenants = JSON.parse(res.body)
                tenants.map{ |tenant| Tenant.new(tenant['tenantId'], tenant['name'], tenant['createdAt']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # List all users for a tenant
        #
        # @return [Array<User>] all users for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def list_users
            return User.list_for_tenant(tenant_id)
        end

        # List pricing tiers for a tenant
        #
        # @return [Array<Feature>] assigned pricing tiers for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_pricing_tiers
            return PricingTier.list_for_tenant(tenant_id)
        end

        # Assign a pricing tier to a tenant
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign to the tenant.
        #
        # @return [PricingTier] assigned pricing tier
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_pricing_tier(pricing_tier_id)
            return PricingTier.assign_to_tenant(tenant_id, pricing_tier_id)
        end

        # Remove a pricing_tier from a tenant
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing_tier you want to remove from the tenant.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_pricing_tier(pricing_tier_id)
            return PricingTier.remove_from_tenant(tenant_id, pricing_tier_id)
        end

        # List features for a tenant
        #
        # @return [Array<Feature>] assigned features for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_features
            return Feature.list_for_tenant(tenant_id)
        end

        # Assign a feature to a tenant
        #
        # @param feature_id [String] The feature_id of the feature you want to assign to the tenant.
        #
        # @return [Feature] assigned feature
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_feature(feature_id)
            return Feature.assign_to_tenant(tenant_id, feature_id)
        end

        # Remove a feature from a tenant
        #
        # @param feature_id [String] The feature_id of the feature you want to remove from the tenant.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_feature(feature_id)
            return Feature.remove_from_tenant(tenant_id, feature_id)
        end

        # Check whether a tenant has a given feature
        #
        # @param feature_id [String] The feature_id of the feature to check whether the tenant has access to.
        #
        # @ return [Boolean] whether or not the tenant has the given feature
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def has_feature?(feature_id, opts = {})
            return Warrant.has_feature?(
                feature_id: feature_id,
                subject: {
                    object_type: "tenant",
                    object_id: tenant_id
                },
                consistent_read: opts[:consistent_read],
                debug: opts[:debug]
            )
        end
    end
end
