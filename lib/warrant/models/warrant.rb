# frozen_string_literal: true

module Warrant
    class Warrant
        attr_reader :id, :object_type, :object_id, :relation, :subject, :policy, :warrant_token

        # @!visibility private
        def initialize(object_type, object_id, relation, subject, policy = nil, warrant_token = nil)
            @object_type = object_type
            @object_id = object_id
            @relation = relation
            @subject = subject
            @policy = policy
            @warrant_token = warrant_token
        end

        # Create a new warrant that associates an object (object_type and object_id) to a subject via a relation.
        #
        # @param object [WarrantObject | Hash] The object to which the warrant will apply. Can be a hash with object type and id or an instance of a class that implements the WarrantObject module and its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @param relation [String] The relation for this object to subject association. The relation must be valid as per the object type definition.
        # @param subject [WarrantObject | Hash] The subject for which the warrant will apply. Can be a hash with object type and id and an optional relation or an instance of a class that implements the WarrantObject module and its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @param policy [String] - A boolean expression that must evaluate to true for this warrant to apply. The expression can reference variables that are provided in the context attribute of access check requests. (optional)
        #
        # @return [Warrant] created warrant
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.create(object, relation, subject, policy = nil, options = {})
            params = {
                object_type: object.respond_to?(:warrant_object_type) ? object.warrant_object_type.to_s : object[:object_type],
                object_id: object.respond_to?(:warrant_object_id) ? object.warrant_object_id.to_s : object[:object_id],
                relation: relation,
                subject: {
                    object_type: subject.respond_to?(:warrant_object_type) ? subject.warrant_object_type.to_s : subject[:object_type],
                    object_id: subject.respond_to?(:warrant_object_id) ? subject.warrant_object_id.to_s : subject[:object_id]
                },
                policy: policy
            }
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v2/warrants"), params: Util.normalize_params(params), options: options)

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body, symbolize_names: true)
                subject = Subject.new(res_json[:subject][:objectType], res_json[:subject][:objectId], res_json[:subject][:relation])
                Warrant.new(res_json[:objectType], res_json[:objectId], res_json[:relation], subject, res_json[:policy], res['Warrant-Token'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Batch creates multiple warrants with given parameters
        #
        # @param [Array<Hash>] warrants Array of warrants to create.
        # @option warrants [WarrantObject | Hash] :object The object to which the warrant will apply. Object can be a hash with object type and id or an instance of a class that implements the WarrantObject module and its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @option warrants [String] :relation The relation for this object to subject association. The relation must be valid as per the object type definition.
        # @option warrants [WarrantObject | Hash] :subject The subject for which the warrant will apply. Can be a hash with object type and id and an optional relation or an instance of a class that implements the WarrantObject module and its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @option warrants [String] :policy A boolean expression that must evaluate to true for this warrant to apply. The expression can reference variables that are provided in the context attribute of access check requests. (optional)
        #
        # @return [Array<Warrant>] all created warrants
        #
        # @raise [Warrant::DuplicateRecordError]
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.batch_create(warrants, options = {})
            mapped_warrants = warrants.map{ |warrant|
                {
                    object_type: warrant[:object].respond_to?(:warrant_object_type) ? warrant[:object].warrant_object_type.to_s : warrant[:object_type],
                    object_id: warrant[:object].respond_to?(:warrant_object_id) ? warrant[:object].warrant_object_id.to_s : warrant[:object_id],
                    relation: warrant[:relation],
                    subject: {
                        object_type: warrant[:subject].respond_to?(:warrant_object_type) ? warrant[:subject].warrant_object_type.to_s : warrant[:subject][:object_type],
                        object_id: warrant[:subject].respond_to?(:warrant_object_id) ? warrant[:subject].warrant_object_id.to_s : warrant[:subject][:object_id]
                    },
                    policy: warrant[:policy]
                }
            }
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v2/warrants"), params: Util.normalize_params(mapped_warrants), options: options)

            case res
            when Net::HTTPSuccess
                res_json = JSON.parse(res.body, symbolize_names: true)
                res_json.map{ |warrant|
                    subject = Subject.new(warrant[:subject][:objectType], warrant[:subject][:objectId], warrant[:subject][:relation])
                    Warrant.new(warrant[:objectType], warrant[:objectId], warrant[:relation], subject, warrant[:policy], res['Warrant-Token'])
                }
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a warrant specified by the combination of object_type, object_id, relation, and subject.
        #
        # @param object [WarrantObject | Hash] The object to which the warrant applies. Can be a hash with object type and id or an instance of a class that implements the WarrantObject module and its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @param relation [String] The relation for this object to subject association. The relation must be valid as per the object type definition.
        # @param subject [WarrantObject | Hash] The subject to for which the warrant applies. Can be a hash with object type and id and an optional relation or an instance of a class that implements the WarrantObject module and its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @param policy [String] - A boolean expression that must evaluate to true for this warrant to apply. The expression can reference variables that are provided in the context attribute of access check requests. (optional)
        #
        # @return [nil] if delete was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.delete(object, relation, subject, policy = nil, options = {})
            params = {
                object_type: object.respond_to?(:warrant_object_type) ? object.warrant_object_type.to_s : object[:object_type],
                object_id: object.respond_to?(:warrant_object_id) ? object.warrant_object_id.to_s : object[:object_id],
                relation: relation,
                subject: {
                    object_type: subject.respond_to?(:warrant_object_type) ? subject.warrant_object_type.to_s : subject[:object_type],
                    object_id: subject.respond_to?(:warrant_object_id) ? subject.warrant_object_id.to_s : subject[:object_id]
                },
                policy: policy
            }
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v2/warrants"), params: Util.normalize_params(params), options: options)

            case res
            when Net::HTTPSuccess
                return res['Warrant-Token']
            else
                APIOperations.raise_error(res)
            end
        end

        # Batch deletes multiple warrants with given parameters
        #
        # @param [Array<Hash>] warrants Array of warrants to delete.
        # @option warrants [WarrantObject | Hash] :object The object to which the warrant applies. Can be a hash with object type and id or an instance of a class that implements the WarrantObject module and its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @option warrants [String] :relation The relation for this object to subject association. The relation must be valid as per the object type definition.
        # @option warrants [WarrantObject | Hash] :subject The subject for which the warrant applies. Can be a hash with object type and id and an optional relation or an instance of a class that implements the WarrantObject module and its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @option warrants [String] :policy A boolean expression that must evaluate to true for this warrant to apply. The expression can reference variables that are provided in the context attribute of access check requests. (optional)
        #
        # @return [nil] if delete was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.batch_delete(warrants, options = {})
            mapped_warrants = warrants.map{ |warrant|
                {
                    object_type: warrant[:object].respond_to?(:warrant_object_type) ? warrant[:object].warrant_object_type.to_s : warrant[:object_type],
                    object_id: warrant[:object].respond_to?(:warrant_object_id) ? warrant[:object].warrant_object_id.to_s : warrant[:object_id],
                    relation: warrant[:relation],
                    subject: {
                        object_type: warrant[:subject].respond_to?(:warrant_object_type) ? warrant[:subject].warrant_object_type.to_s : warrant[:subject][:object_type],
                        object_id: warrant[:subject].respond_to?(:warrant_object_id) ? warrant[:subject].warrant_object_id.to_s : warrant[:subject][:object_id]
                    },
                    policy: warrant[:policy]
                }
            }
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v2/warrants"), params: Util.normalize_params(mapped_warrants), options: options)

            case res
            when Net::HTTPSuccess
                return res['Warrant-Token']
            else
                APIOperations.raise_error(res)
            end
        end

        # List all warrants for your organization and environment
        #
        # @param [Hash] filters Filters to apply to result set
        # @param [Hash] options Options to apply on a per-request basis
        # @option filters [String] :object_type _Required if object_id is provided._ Only return warrants whose object_type matches this value. (optional)
        # @option filters [String] :object_id Only return warrants whose object_id matches this value. (optional)
        # @option filters [String] :relation Only return warrants whose relation matches this value. (optional)
        # @option filters [String] :subject_type Required if :subjectId is provided. Only return warrants with a subject whose objectType matches this value. (optional)
        # @option filters [String] :subject_id Only return warrants with a subject whose object_id matches this value. (optional)
        # @option filters [String] :subject_relation Only return warrants with a subject whose relation matches this value. (optional)
        # @option filters [Integer] :limit A positive integer representing the maximum number of items to return in the response. Must be less than or equal to 1000. Defaults to 25. (optional)
        # @option filters [String] :prev_cursor A cursor representing your place in a list of results. Requests containing prev_cursor will return the results immediately preceding the cursor. (optional)
        # @option filters [String] :next_cursor A cursor representing your place in a list of results. Requests containing next_cursor will return the results immediately following the cursor. (optional)
        # @option filters [String] :sort_by The column to sort the result by. Unless otherwise specified, all list endpoints are sorted by their unique identifier by default. Supported values for objects are +object_type+, +object_id+, and +created_at+ (optional)
        # @option filters [String] :sort_order The order in which to sort the result by. Valid values are +ASC+ and +DESC+. Defaults to +ASC+. (optional)
        # @option options [String] :warrant_token A valid warrant token from a previous write operation or latest. Used to specify desired consistency for this read operation. (optional)
        #
        # @return [Array<Warrant>] all permissions for your organization
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::UnauthorizedError]
        def self.list(filters = {}, options = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v2/warrants"), params: Util.normalize_params(filters), options: options)

            case res
            when Net::HTTPSuccess
                list_result = JSON.parse(res.body, symbolize_names: true)
                warrants = list_result[:results].map{ |warrant|
                    subject = Subject.new(warrant[:subject][:objectType], warrant[:subject][:objectId], warrant[:subject][:relation])
                    Warrant.new(warrant[:objectType], warrant[:objectId], warrant[:relation], subject, warrant[:policy])
                }
                return ListResponse.new(warrants, list_result[:prevCursor], list_result[:nextCursor])
            else
                APIOperations.raise_error(res)
            end
        end

        # Query to find all warrants for a given object or subject.
        #
        # @param warrant_query [String] Query to run for a set of warrants.
        # @option filters [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option filters [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Hash] Query result with `result` listing warrants returned and `meta` with metadata for the selected object types.
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.query(query, filters: {}, options: {})
            params = filters.merge(q: query)
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v2/query"), params: Util.normalize_params(params), options: options)

            case res
            when Net::HTTPSuccess
                query_response = JSON.parse(res.body, symbolize_names: true)
                query_results = query_response[:results].map{ |result|
                    subject = Subject.new(result[:warrant][:subject][:objectType], result[:warrant][:subject][:objectId], result[:warrant][:subject][:relation])
                    warrant = Warrant.new(result[:warrant][:objectType], result[:warrant][:objectId], result[:warrant][:relation], subject, result[:warrant][:policy])
                    QueryResult.new(result[:objectType], result[:objectId], warrant, result[:isImplicit], result[:meta])
                }
                return ListResponse.new(query_results, query_response[:prevCursor], query_response[:nextCursor])
            else
                APIOperations.raise_error(res)
            end
        end

        # Checks whether a specified access check is authorized or not.
        # If you would like to check only one warrant, then you can exclude the op param and provide an array with one warrant.
        #
        # @param op [String] Logical operator to perform on warrants. Can be 'anyOf' or 'allOf'. (optional)
        # @param warrants [Array] Array of warrants to check access for.
        #   * object_type (String) - The type of object. Must be one of your system's existing object types.
        #   * object_id (String) - The id of the specific object.
        #   * relation (String) - The relation to check for this object to subject association. The relation must be valid as per the object type definition.
        #   * subject (Hash) - The specific subject for which access will be checked. Can be a specific object by id or an objectType, objectId and relation set.
        #       * object_type (String) - The type of object. Must be one of your system's existing object types.
        #       * object_id (String) - The id of the specific object.
        #       * relation (String) - The relation for this object to subject association. The relation must be valid as per the object type definition. (optional)
        #   * context [Hash] - Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @param debug [Boolean] Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the given access check is authorized
        #
        # @example Check whether user "5djfs6" can view the report with id "avk2837"
        #   Warrant::Warrant.is_authorized?(warrants: [{ object_type: "report", object_id: "avk2837", relation: "viewer", subject: { object_type: "user", object_id: "5djfs6" } }])
        #
        # @example Check whether user "5djfs6" can view both report id "report-1" and report id "report-2"
        #   Warrant::Warrant.is_authorized?(
        #       op: "allOf",
        #       warrants: [
        #           { object_type: "report", object_id: "report-1", relation: "viewer", subject: { object_type: "user", object_id: "5djfs6" } }
        #           { object_type: "report", object_id: "report-2", relation: "viewer", subject: { object_type: "user", object_id: "5djfs6" } }
        #       ]
        #   )
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.is_authorized?(params = {}, options = {})
            unless ::Warrant.config.authorize_endpoint.nil?
                return edge_authorize?(params, options)
            end

            return authorize?(params, options)
        end

        # Checks whether a specified access check is authorized or not.
        #
        # @param object [WarrantObject] Object to check in the access check. Object must include WarrantObject module and implements its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @param relation [String] The relation to check for this object to subject association. The relation must be valid as per the object type definition.
        # @param subject [WarrantObject] Subject to check in the access check. Subject must include WarrantObject module and implements its methods (`warrant_object_type` and `warrant_object_id`).
        # @option options [Hash] :context Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @option options [Boolean] :debug Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the given access check is authorized
        #
        # @example Check whether the user has "viewer" relation to report. `Report` and `User` here are both classes in your application that include `WarrantObject`.
        #   my_report = Report.get("some-report")
        #   current_user = User.get("llm-128")
        #   Warrant::Warrant.is_authorized?(my_report, "viewer", current_user)
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.check(object, relation, subject, options = {})
            if object.is_a?(WarrantObject)
                object_type = object.warrant_object_type.to_s
                object_id = object.warrant_object_id.to_s
            else
                object_type = object[:object_type]
                object_id = object[:object_id]
            end

            if subject.is_a?(Subject)
                subject = {
                    object_type: subject.object_type,
                    object_id: subject.object_id,
                    relation: subject.relation
                }.compact!
            elsif subject.is_a?(WarrantObject)
                subject = {
                    object_type: subject.warrant_object_type.to_s,
                    object_id: subject.warrant_object_id.to_s
                }
            end

            unless ::Warrant.config.authorize_endpoint.nil?
                return edge_authorize?(
                    warrants: [{
                        object_type: object_type,
                        object_id: object_id,
                        relation: relation,
                        subject: subject,
                        context: options[:context]
                    }],
                    debug: options[:debug]
                )
            end

            return authorize?(
                warrants: [{
                    object_type: object_type,
                    object_id: object_id,
                    relation: relation,
                    subject: subject,
                    context: options[:context]
                }],
                debug: options[:debug]
            )
        end

        # Checks whether multiple access checks are authorized or not.
        #
        # @param op [String] Logical operator to perform on warrants. Can be 'anyOf' or 'allOf'.
        # @param warrants [Array] Array of warrants to check access for.
        #   * object (WarrantObject) - Object to check in the access check. Object must include WarrantObject module and implements its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        #   * relation (String) - The relation to check for this object to subject association. The relation must be valid as per the object type definition.
        #   * subject (WarrantObject) Subject to check in the access check. Subject must include WarrantObject module and implements its methods (`warrant_object_type` and `warrant_object_id`).
        # @option options [Hash] :context Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @option options [Boolean] :debug Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the given access check is authorized
        #
        # @example Check whether the current user has "viewer" relation to report and is a "member" of the customer account "superstore". `Report`, `CustomerAccount` and `User` here are all classes in your application that include `WarrantObject`.
        #   my_report = Report.get("some-report")
        #   customer_account = CustomerAccount.get("superstore")
        #   current_user = User.get("llm-128")
        #   Warrant::Warrant.check_many(
        #       "allOf",
        #       [
        #           { object: my_report, relation: "viewer", subject: current_user },
        #           { object: customer_account, relation: "member", subject: current_user }
        #       ]
        #   )
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.check_many(op, warrants, options = {})
            normalized_warrants = warrants.map do |warrant|
                if warrant[:object].is_a?(WarrantObject)
                    object_type = warrant[:object].warrant_object_type.to_s
                    object_id = warrant[:object].warrant_object_id.to_s
                else
                    object_type = warrant[:object][:object_type]
                    object_id = warrant[:object][:object_id]
                end

                if warrant[:subject].is_a?(Subject)
                    subject = {
                        object_type: warrant[:subject].object_type,
                        object_id: warrant[:subject].object_id,
                        relation: warrant[:subject].relation
                    }.compact!
                elsif warrant[:subject].is_a?(WarrantObject)
                    subject = {
                        object_type: warrant[:subject].warrant_object_type.to_s,
                        object_id: warrant[:subject].warrant_object_id.to_s
                    }
                else
                    subject = warrant[:subject]
                end

                {
                    object_type: object_type,
                    object_id: object_id,
                    relation: warrant[:relation],
                    subject: subject,
                    context: warrant[:context]
                }
            end

            unless ::Warrant.config.authorize_endpoint.nil?
                return edge_authorize?({
                    op: op,
                    warrants: normalized_warrants,
                    debug: options[:debug]
                }, options)
            end

            return authorize?({
                op: op,
                warrants: normalized_warrants,
                debug: options[:debug]
            }, options)
        end

        # Checks whether a given user has a given permission.
        #
        # @param user_id [String] Id of the user to check
        # @param permission_id [String] Id of the permission to check on the user
        # @param context [Hash] - Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @param debug [Boolean] Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the user has the given permission
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.user_has_permission?(params = {}, options = {})
            return is_authorized?({
                warrants: [{
                    object_type: Permission::OBJECT_TYPE,
                    object_id: params[:permission_id],
                    relation: params[:relation],
                    subject: {
                        object_type: User::OBJECT_TYPE,
                        object_id: params[:user_id]
                    },
                    context: params[:context]
                }],
                debug: params[:debug]
            }, options)
        end

        # Checks whether a given subject has a given feature.
        #
        # @param subject (Hash) - The specific subject for which feature access will be checked.
        #   * object_type (String) - The type of object. Must be one of your system's existing object types.
        #   * object_id (String) - The id of the specific object.
        # @param feature_id [String] Id of the feature to check on the subject
        # @param context [Hash] - Object containing key-value pairs that specifies the context the warrant should be checked in. (optional)
        # @param debug [Boolean] Boolean flag indicating whether or not to return debug information for this access check. Defaults to false. (optional)
        #
        # @return [Boolean] whether or not the user has the given permission
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        def self.has_feature?(params = {}, options = {})
            return is_authorized?({
                warrants: [{
                    object_type: Feature::OBJECT_TYPE,
                    object_id: params[:feature_id],
                    relation: params[:relation],
                    subject: {
                        object_type: params[:subject][:object_type],
                        object_id: params[:subject][:object_id]
                    },
                    context: params[:context]
                }],
                debug: params[:debug]
            }, options)
        end

        private

        def self.authorize?(params = {}, options = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v2/check"), params: Util.normalize_params(params), options: options)
            res_json = JSON.parse(res.body)

            case res
            when Net::HTTPSuccess
                if res_json['result'] === "Authorized"
                    return true
                elsif res_json['result'] === "Not Authorized"
                    return false
                else
                    return res_json
                end
            else
                APIOperations.raise_error(res)
            end
        end

        def self.edge_authorize?(params = {}, options = {})
            request_url = URI.parse("#{::Warrant.config.authorize_endpoint}/v2/check")
            res = APIOperations.post(request_url, params: Util.normalize_params(params), options: options)
            res_json = JSON.parse(res.body)

            case res
            when Net::HTTPSuccess
                if res_json['result'] === "Authorized"
                    return true
                elsif res_json['result'] === "Not Authorized"
                    return false
                else
                    return res_json
                end
            else
                if res_json['code'] === "cache_not_ready"
                    return authorize(params)
                end

                APIOperations.raise_error(res)
            end
        end
    end
end
