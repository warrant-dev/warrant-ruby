# frozen_string_literal: true

module Warrant
    class Permission
        attr_reader :permission_id
        
        # @!visibility private
        def initialize(permission_id)
            @permission_id = permission_id
        end

        # Creates a permission with the given parameters
        #
        # @option params [String] :permission_id A string identifier for this new permission. The permission_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'. (optional)
        #
        # @return [Permission] if permission was created successfully
        # @return [Hash] if request failed
        #
        # @example Create a new Permission with the permission id "test-permission"
        #   Warrant::Permission.create(permission_id: "test-permission")
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
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/permissions"), Util.normalize_params(params))
            res_json = JSON.parse(res.body)

            case res
            when Net::HTTPSuccess
                Permission.new(res_json['permissionId'])
            else
                res_json
            end
        end

        # Deletes a permission with given permission id
        #
        # @param permission_id [String] A string identifier for this new permission. The permission_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'.
        #
        # @return [void] if delete was successful
        # @return [Hash] if request failed
        #
        # @example Delete a Permission with the permission id "test-permission"
        #   Warrant::Permission.delete("test-permission")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.delete(permission_id)
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/permissions/#{permission_id}"))

            case res
            when Net::HTTPSuccess
                return
            else
                JSON.parse(res.body)
            end
        end

        # Lists all permissions for your organization
        #
        # @return [Array<Permission>] if permissions successfully retrieved
        # @return [Hash] if request failed
        #
        # @example List all permissions
        #   Warrant::Permission.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/permissions"))

            case res
            when Net::HTTPSuccess
                permissions = JSON.parse(res.body)
                permissions.map{ |permission| Permission.new(permission['permissionId']) }
            else
                JSON.parse(res.body)
            end   
        end

        # Get a permission with the given permission_id
        #
        # @param permission_id [String] A string identifier for this new permission. The permission_id can only be composed of lower-case alphanumeric chars and/or '-' and '_'.
        #
        # @return [Permission] if permission was successfully retrieved
        # @return [Hash] if request failed 
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.get(permission_id)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/permissions/#{permission_id}"))

            case res
            when Net::HTTPSuccess
                permission = JSON.parse(res.body)
                Permission.new(permission['permissionId'])
            else
                JSON.parse(res.body)
            end  
        end
    end
end
