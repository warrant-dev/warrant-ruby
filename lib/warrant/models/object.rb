# frozen_string_literal: true

module Warrant
    class Object
        attr_reader :object_type, :object_id, :meta, :created_at

        # @!visibility private
        def initialize(object_type, object_id, meta = {}, created_at = nil)
            @object_type = object_type
            @object_id = object_id
            @meta = meta
            @created_at = created_at
        end

        # Creates an object with the given parameters
        #
        # @option params [String] :object_type The type of the object (e.g. user, tenant, role, permission, etc).
        # @option params [String] :object_id Customer defined string identifier for this object. Can only contain alphanumeric chars and/or '-', '_', '|', '@'. If not provided, Warrant will create a univerally unique identifier (UUID) for the object and return it. If allowing Warrant to generate an id, store the id in your application so you can provide it for authorization requests on that object. (optional)
        # @option params [Hash] :meta A JSON object containing additional information about this object (e.g. role name/description, user email/name, etc.) to be persisted to Warrant. (optional)
        #
        # @return [Object] created object
        #
        # @example Create a new Object with the object type "user" and object id "test-customer"
        #   Warrant::Object.create(object_type: "user", object_id: "test-customer")
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.create(params = {}, options = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v2/objects"), params: Util.normalize_params(params), options: options)

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body, symbolize_names: true)
                Object.new(res_json[:objectType], res_json[:objectId], res_json[:meta], res_json[:createdAt])
            else
                APIOperations.raise_error(res)
            end
        end

        # Batch creates multiple objects with given parameters
        #
        # @param [Array<Hash>] objects Array of objects to create.
        # @option objects [String] :object_type The type of the object (e.g. user, tenant, role, permission, etc).
        # @option objects [String] :object_id Customer defined string identifier for this object. Can only contain alphanumeric chars and/or '-', '_', '|', '@'. If not provided, Warrant will create a univerally unique identifier (UUID) for the object and return it. If allowing Warrant to generate an id, store the id in your application so you can provide it for authorization requests on that object. (optional)
        # @option objects [Hash] :meta A JSON object containing additional information about this object (e.g. role name/description, user email/name, etc.) to be persisted to Warrant. (optional)
        #
        # @return [Array<Object>] all created objects
        #
        # @example Create two new objects with object type "user" and object ids "test-user-1" and "test-user-2"
        #   Warrant::Object.batch_create([{ object_type: "user", object_id: "test-user-1" }, { object_type: "user", object_id: "test-user-2" }])
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.batch_create(objects, options = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v2/objects"), params: Util.normalize_params(objects), options: options)

            case res
            when Net::HTTPSuccess
                objects = JSON.parse(res.body, symbolize_names: true)
                objects.map{ |object| Object.new(object[:objectType], object[:objectId], object[:meta], object[:createdAt]) }
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a object with given object type and id
        #
        # @param object_type [String] The type of the object (e.g. user, tenant, role, permission, etc).
        # @param object_id [String] User defined string identifier for this object.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete a Object with the object type "user" and object id "test-customer"
        #   Warrant::Object.delete("user", "test-customer")
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.delete(object_type, object_id, options = {})
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v2/objects/#{object_type}/#{object_id}"), options: options)

            case res
            when Net::HTTPSuccess
                return res['Warrant-Token']
            else
                APIOperations.raise_error(res)
            end
        end

        # Batch deletes multiple objects with given parameters
        #
        # @param [Array<Hash>] objects Array of objects to delete.
        # @option objects [String] :object_type The type of the object (e.g. user, tenant, role, permission, etc).
        # @option objects [String] :object_id Customer defined string identifier for this object.
        #
        # @return [nil] if delete was successful
        #
        # @example Delete two objects with object type "user" and object ids "test-user-1" and "test-user-2"
        #   Warrant::Object.batch_delete([{ object_type: "user", object_id: "test-user-1" }, { object_type: "user", object_id: "test-user-2" }])
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.batch_delete(objects, options = {})
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v2/objects"), params: Util.normalize_params(objects), options: options)

            case res
            when Net::HTTPSuccess
                return res['Warrant-Token']
            else
                APIOperations.raise_error(res)
            end
        end

        # Lists all objects for your organization and environment
        #
        # @param [Hash] filters Filters to apply to result set
        # @param [Hash] options Options to apply on a per-request basis
        # @option filters [String] :object_type Only return objects with an +object_type+ matching this value
        # @option filters [Integer] :limit A positive integer representing the maximum number of items to return in the response. Must be less than or equal to 1000. Defaults to 25. (optional)
        # @option filters [String] :prev_cursor A cursor representing your place in a list of results. Requests containing prev_cursor will return the results immediately preceding the cursor. (optional)
        # @option filters [String] :next_cursor A cursor representing your place in a list of results. Requests containing next_cursor will return the results immediately following the cursor. (optional)
        # @option filters [String] :sort_by The column to sort the result by. Unless otherwise specified, all list endpoints are sorted by their unique identifier by default. Supported values for objects are +object_type+, +object_id+, and +created_at+ (optional)
        # @option filters [String] :sort_order The order in which to sort the result by. Valid values are +ASC+ and +DESC+. Defaults to +ASC+. (optional)
        # @option options [String] :warrant_token A valid warrant token from a previous write operation or latest. Used to specify desired consistency for this read operation. (optional)
        #
        # @return [Array<Object>] all objects for your organization and environment
        #
        # @example List all objects
        #   Warrant::Object.list()
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {}, options = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v2/objects"), params: Util.normalize_params(filters), options: options)

            case res
            when Net::HTTPSuccess
                list_result = JSON.parse(res.body, symbolize_names: true)
                objects = list_result[:results].map{ |object| Object.new(object[:objectType], object[:objectId], object[:meta], object[:createdAt]) }
                return ListResponse.new(objects, list_result[:prevCursor], list_result[:nextCursor])
            else
                APIOperations.raise_error(res)
            end
        end

        # Get a object with the given object_type and object_id
        #
        # @param object_id [String] Object defined string identifier for this object. If not provided, Warrant will create an id for the object and return it. In this case, you should store the id in your system as you will need to provide it for any authorization requests for that object. Note that objectIds in Warrant must be composed of alphanumeric chars and/or '-', '_', and '@'.
        #
        # @return [Object] retrieved object
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.get(object_type, object_id, options = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v2/objects/#{object_type}/#{object_id}"), options: options)

            case res
            when Net::HTTPSuccess
                object = JSON.parse(res.body, symbolize_names: true)
                Object.new(object[:objectType], object[:objectId], object[:meta], object[:createdAt])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates a object with the given object_type and object_id and params
        #
        # @param object_type [String] The type of the object (e.g. user, tenant, role, permission, etc).
        # @param object_id [String] User defined string identifier for this object.
        # @param meta [Hash] A JSON object containing additional information about this object (e.g. role name/description, user email/name, etc.) to be persisted to Warrant.
        #
        # @return [Object] updated object
        #
        # @example Update user "test-user"'s email
        #   Warrant::Object.update("user", "test-user", { email: "my-new-email@example.com" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.update(object_type, object_id, meta, options = {})
            params = {
                meta: meta,
            }
            res = APIOperations.put(URI.parse("#{::Warrant.config.api_base}/v2/objects/#{object_type}/#{object_id}"), params: Util.normalize_params(params), options: options)

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body, symbolize_names: true)
                Object.new(res_json[:objectType], res_json[:objectId], res_json[:meta], res_json[:createdAt])
            else
                APIOperations.raise_error(res)
            end
        end

        # Updates a object with the given object_type and object_id and params
        #
        # @param meta [Hash] A JSON object containing additional information about this object (e.g. role name/description, user email/name, etc.) to be persisted to Warrant.
        #
        # @return [Object] updated object
        #
        # @example Update user "test-user"'s email
        #   user = Warrant::Object.get("user", "test-user")
        #   user.update({ email: "my-new-email@example.com" })
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def update(meta, options = {})
            return Object.update(object_type, object_id, meta, options)
        end
    end
end
