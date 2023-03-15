# frozen_string_literal: true

module Warrant
    class User
        OBJECT_TYPE = "user"

        include Warrant::WarrantObject

        attr_reader :user_id, :email, :created_at

        # @!visibility private
        def initialize(user_id, email, created_at)
            @user_id = user_id
            @email = email
            @created_at = created_at
        end

        # Creates a user with the given parameters
        #
        # @option params [String] :user_id User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        # @option params [String] :email Email address for this user. Designed to be used as a UI-friendly identifier. (optional)
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
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/users"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                User.new(res_json['userId'], res_json['email'], res_json['createdAt'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Batch creates multiple users with given parameters
        #
        # @param [Array] Array of users to create.
        #   * user_id User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system for future reference. Note that tenantIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'. (optional)
        #   * email Email address for this user. Designed to be used as a UI-friendly identifier. (optional)
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
        def self.batch_create(users = [])
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/users"), Util.normalize_params(users))

            case res
            when Net::HTTPSuccess
                users = JSON.parse(res.body)
                users.map{ |user| User.new(user['userId'], user['email'], user['createdAt']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a user with given user id
        #
        # @param user_id [String] User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
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
        def self.delete(user_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Lists all users for your organization
        #
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<User>] all users for your organization
        #
        # @example List all users
        #   Warrant::User.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users"), Util.normalize_params(filters))

            case res
            when Net::HTTPSuccess
                users = JSON.parse(res.body)
                users.map{ |user| User.new(user['userId'], user['email'], user['createdAt']) }
            else
                APIOperations.raise_error(res)
            end
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
        def self.get(user_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}"))

            case res
            when Net::HTTPSuccess
                user = JSON.parse(res.body)
                User.new(user['userId'], user['email'], user['createdAt'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates a user with the given user_id and params
        #
        # @param user_id [String] User defined string identifier for this user. If not provided, Warrant will create an id for the user and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that user. Note that userIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        # @param [Hash] params attributes to update user with
        # @option params [String] :email Email address for this user. Designed to be used as a UI-friendly identifier. (optional)
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
        def self.update(user_id, params = {})
            res = APIOperations.put(URI.parse("#{::Warrant.config.api_base}/v1/users/#{user_id}"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body)
                User.new(res_json['userId'], res_json['email'], res_json['createdAt'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates the user with the given params
        #
        # @option params [String] :email Email address for this user. Designed to be used as a UI-friendly identifier. (optional)
        #
        # @return [User] updated user
        #
        # @example Update user "test-user"'s email
        #   user = Warrant::User.get("test-user")
        #   user.update(email: "my-new-email@example.com")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(params = {})
            return User.update(user_id, params)
        end

        # List all roles for a user.
        #
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<Role>] all roles for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_roles(filters = {})
            return Role.list_for_user(user_id, filters)
        end

        # Assign a role to a user
        #
        # @param user_id [String] The user_id of the user you want to assign a role to.
        # @param role_id [String] The role_id of the role you want to assign to a user.
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
        def assign_role(role_id)
            return Role.assign_to_user(user_id, role_id)
        end

        # Remove a role from a user
        #
        # @param user_id [String] The user_id of the role you want to assign a role to.
        # @param role_id [String] The role_id of the role you want to assign to a user.
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
        def remove_role(role_id)
            return Role.remove_from_user(user_id, role_id)
        end

        # List all permissions for a user
        #
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<Permission>] all permissions for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_permissions(filters = {})
            return Permission.list_for_user(user_id, filters)
        end

        # Assign a permission to a user
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to a user.
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
        def assign_permission(permission_id)
            return Permission.assign_to_user(user_id, permission_id)
        end

        # Remove a permission from a user
        #
        # @param permission_id [String] The permission_id of the permission you want to assign to a user.
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
        def remove_permission(permission_id)
            Permission.remove_from_user(user_id, permission_id)
        end

        # Checks whether a user has a given permission
        #
        # @param permission_id [String] The permission_id of the permission you want to check whether or not it exists on the user.
        # @option options [Hash] :context Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @option options [Boolean] :consistent_read Boolean flag indicating whether or not to enforce strict consistency for this access check. Defaults to false. (optional)
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
        def has_permission?(permission_id, opts = {})
            return Warrant.user_has_permission?(
                permission_id: permission_id,
                user_id: user_id,
                context: opts[:context],
                consistent_read: opts[:consistent_read],
                debug: opts[:debug]
            )
        end

        # List all users for a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant from which to fetch users
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<User>] all users for the tenant
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list_for_tenant(tenant_id, filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/tenants/#{tenant_id}/users"), Util.normalize_params(filters))

            case res
            when Net::HTTPSuccess
                users = JSON.parse(res.body)
                users.map{ |user| User.new(user['userId'], user['email'], user['createdAt']) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Add a user to a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to assign a user to.
        # @param user_id [String] The user_id of the user you want to add to the tenant.
        #
        # @return [Warrant] warrant assigning user to the tenant
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.assign_to_tenant(tenant_id, user_id)
            Warrant.create({ object_type: Tenant::OBJECT_TYPE, object_id: tenant_id }, "member", { object_type: User::OBJECT_TYPE, object_id: user_id })
        end

        # Remove a user from a tenant
        #
        # @param tenant_id [String] The tenant_id of the tenant you want to remove the user from.
        # @param user_id [String] The user_id of the user you want to remove from the tenant.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.remove_from_tenant(tenant_id, user_id)
            Warrant.delete({ object_type: Tenant::OBJECT_TYPE, object_id: tenant_id }, "member", { object_type: User::OBJECT_TYPE, object_id: user_id })
        end

        # List all tenants for a user
        #
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<Tenant>] all tenants for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def list_tenants(filters = {})
            return Tenant.list_for_user(user_id, filters)
        end

        # List pricing tiers for a user
        #
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<PricingTier>] assigned pricing tiers for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_pricing_tiers(filters = {})
            return PricingTier.list_for_user(user_id, filters)
        end

        # Assign a pricing tier to a user
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign to the user.
        #
        # @return [PricingTier] assigned pricing tier
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_pricing_tier(pricing_tier_id)
            return PricingTier.assign_to_user(user_id, pricing_tier_id)
        end

        # Remove a pricing tier from a user
        #
        # @param pricing_tier_id [String] The pricing_tier_id of the pricing tier you want to assign from the user.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_pricing_tier(pricing_tier_id)
            return PricingTier.remove_from_user(user_id, pricing_tier_id)
        end

        # List features for a user
        #
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<Feature>] assigned features for the user
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def list_features(filters = {})
            return Feature.list_for_user(user_id, filters)
        end

        # Assign a feature to a user
        #
        # @param feature_id [String] The feature_id of the feature you want to assign to the user.
        #
        # @return [Feature] assigned feature
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def assign_feature(feature_id)
            return Feature.assign_to_user(user_id, feature_id)
        end

        # Remove a feature from a user
        #
        # @param feature_id [String] The feature_id of the feature you want to assign from the user.
        #
        # @return [nil] if remove was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def remove_feature(feature_id)
            return Feature.remove_from_user(user_id, feature_id)
        end

        # Check whether a user has a given feature
        #
        # @param feature_id [String] The feature_id of the feature to check whether the user has access to.
        # @option options [Hash] :context Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @option options [Boolean] :consistent_read Boolean flag indicating whether or not to enforce strict consistency for this access check. Defaults to false. (optional)
        # @option options [Boolean] :debug Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @ return [Boolean] whether or not the user has the given feature
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def has_feature?(feature_id, opts = {})
            return Warrant.has_feature?(
                feature_id: feature_id,
                subject: {
                    object_type: "user",
                    object_id: user_id
                },
                context: opts[:context],
                consistent_read: opts[:consistent_read],
                debug: opts[:debug]
            )
        end

        def warrant_object_type
            "user"
        end

        def warrant_object_id
            user_id
        end
    end
end
