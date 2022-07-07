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
        # @return [Tenant] if tenant was created successfully
        # @return [Hash] if request failed
        #
        # @example Create a new Tenant with the tenant id "test-customer"
        #   Warrant::Tenant.create(tenant_id: "test-customer")
        # 
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
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

        # Deletes a tenant with given tenant id
        #
        # @param tenant_id [String] User defined string identifier for this tenant. If not provided, Warrant will create an id for the tenant and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        #
        # @return [void] if delete was successful
        # @return [Hash] if request failed
        #
        # @example Delete a Tenant with the tenant id "test-customer"
        #   Warrant::Tenant.delete("test-customer")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
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
        # @return [Array<Tenant>] if tenants successfully retrieved
        # @return [Hash] if request failed
        #
        # @example List all tenants
        #   Warrant::Tenant.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
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
        # @return [Tenant] if tenant was successfully retrieved
        # @return [Hash] if request failed 
        # 
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
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
        # @return [Tenant] if tenant was successfully updated
        # @return [Hash] if request failed 
        #
        # @example Update tenant "test-tenant"'s name
        #   Warrant::Tenant.update("test-tenant", { name: "my-new-name@example.com" })
        # 
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
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
        # @return [Tenant] if tenant was successfully updated
        # @return [Hash] if request failed 
        #
        # @example Update tenant "test-tenant"'s name
        #   tenant = Warrant::Tenant.get("test-tenant")
        #   tenant.update(name: "my-new-name@example.com")
        # 
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def update(params = {})
            return Tenant.update(tenant_id, params)
        end
    end
end
