# frozen_string_literal: true

module Warrant
    class Warrant
        attr_reader :id, :object_type, :object_id, :relation, :subject, :policy, :is_implicit

        # @!visibility private
        def initialize(object_type, object_id, relation, subject, policy = nil, is_implicit = nil)
            @object_type = object_type
            @object_id = object_id
            @relation = relation
            @subject = subject
            @policy = policy
            @is_implicit = is_implicit
        end

        # Create a new warrant that associates an object (object_type and object_id) to a subject via a relation.
        #
        # @param object [WarrantObject | Hash] Object to check in the access check. Object must include WarrantObject module and implements its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @param relation [String] The relation to check for this object to subject association. The relation must be valid as per the object type definition.
        # @param subject [WarrantObject | Hash] Subject to check in the access check. Subject must include WarrantObject module and implements its methods (`warrant_object_type` and `warrant_object_id`).
        # @param policy [String] - A boolean expression that must evaluate to `true` for this warrant to apply. The expression can reference variables that are provided in the `context` attribute of access check requests. (optional)
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
        def self.create(object, relation, subject, policy = nil)
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
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/warrants"), Util.normalize_params(params))
            res_json = JSON.parse(res.body)

            case res
            when Net::HTTPSuccess
                subject = Subject.new(res_json['subject']['objectType'], res_json['subject']['objectId'], res_json['subject']['relation'])
                Warrant.new(res_json['objectType'], res_json['objectId'], res_json['relation'], subject, res_json['policy'])
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a warrant specified by the combination of object_type, object_id, relation, and subject.
        #
        # @param object [WarrantObject | Hash] Object to check in the access check. Object must include WarrantObject module and implements its methods (`warrant_object_type` and `warrant_object_id`). The object type must be one of your system's existing object type.
        # @param relation [String] The relation to check for this object to subject association. The relation must be valid as per the object type definition.
        # @param subject [WarrantObject | Hash] Subject to check in the access check. Subject must include WarrantObject module and implements its methods (`warrant_object_type` and `warrant_object_id`).
        # @param policy [String] - A boolean expression that must evaluate to `true` for this warrant to apply. The expression can reference variables that are provided in the `context` attribute of access check requests. (optional)
        #
        # @return [nil] if delete was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.delete(object, relation, subject, policy = nil)
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
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/warrants"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Query to find all warrants for a given object or subject.
        #
        # @param warrant_query [WarrantQuery] Query to run for a set of warrants.
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
        def self.query(warrant_query = WarrantQuery.new, filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/query"), { "q": warrant_query.to_query_param, **filters })

            case res
            when Net::HTTPSuccess
                query_result = JSON.parse(res.body)
                query_result['result'] = query_result['result'].map{ |warrant|
                    subject = Subject.new(warrant['subject']['objectType'], warrant['subject']['objectId'], warrant['subject']['relation'])
                    Warrant.new(warrant['objectType'], warrant['objectId'], warrant['relation'], subject, warrant['context'], warrant['isImplicit'])
                }

                if query_result['meta']['feature']
                    query_result['meta']['feature'].each{ |featureId, feature|
                        query_result['meta']['feature'][featureId] = Feature.new(feature['featureId'])
                    }
                end

                if query_result['meta']['pricing-tier']
                    query_result['meta']['pricing-tier'].each{ |pricingTierId, pricingTier|
                        query_result['meta']['pricing-tier'][pricingTierId] = PricingTier.new(pricingTier['pricingTierId'])
                    }
                end

                if query_result['meta']['permission']
                    query_result['meta']['permission'].each{ |permissionId, permission|
                        query_result['meta']['permission'][permissionId] = Permission.new(permission['permissionId'], permission['name'], permission['description'])
                    }
                end

                if query_result['meta']['role']
                    query_result['meta']['role'].each{ |roleId, role|
                        query_result['meta']['role'][roleId] = Role.new(role['roleId'], role['name'], role['description'])
                    }
                end

                if query_result['meta']['user']
                    query_result['meta']['user'].each{ |userId, user|
                        query_result['meta']['user'][userId] = User.new(user['userId'], user['email'], user['createdAt'])
                    }
                end

                if query_result['meta']['tenant']
                    query_result['meta']['tenant'].each{ |tenantId, tenant|
                        query_result['meta']['tenant'][tenantId] = Tenant.new(tenant['tenantId'], tenant['name'], tenant['createdAt'])
                    }
                end

                query_result
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
        def self.is_authorized?(params = {})
            unless ::Warrant.config.authorize_endpoint.nil?
                return edge_authorize?(params)
            end

            return authorize?(params)
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
            if subject.instance_of?(Subject)
                subject = {
                    object_type: subject.object_type,
                    object_id: subject.object_id,
                    relation: subject.relation
                }.compact!
            else
                subject = {
                    object_type: subject.warrant_object_type.to_s,
                    object_id: subject.warrant_object_id.to_s
                }
            end

            unless ::Warrant.config.authorize_endpoint.nil?
                return edge_authorize?(
                    warrants: [{
                        object_type: object.warrant_object_type.to_s,
                        object_id: object.warrant_object_id.to_s,
                        relation: relation,
                        subject: subject,
                        context: options[:context]
                    }],
                    debug: options[:debug]
                )
            end

            return authorize?(
                warrants: [{
                    object_type: object.warrant_object_type.to_s,
                    object_id: object.warrant_object_id.to_s,
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
                if warrant[:subject].instance_of?(Subject)
                    subject = {
                        object_type: warrant[:subject].object_type,
                        object_id: warrant[:subject].object_id,
                        relation: warrant[:subject].relation
                    }.compact!
                else
                    subject = {
                        object_type: warrant[:subject].warrant_object_type.to_s,
                        object_id: warrant[:subject].warrant_object_id.to_s
                    }
                end

                {
                    object_type: warrant[:object].warrant_object_type.to_s,
                    object_id: warrant[:object].warrant_object_id.to_s,
                    relation: warrant[:relation],
                    subject: subject,
                    context: warrant[:context]
                }
            end

            unless ::Warrant.config.authorize_endpoint.nil?
                return edge_authorize?(
                    op: op,
                    warrants: normalized_warrants,
                    debug: options[:debug]
                )
            end

            return authorize?(
                op: op,
                warrants: normalized_warrants,
                debug: options[:debug]
            )
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
        def self.user_has_permission?(params = {})
            return is_authorized?(
                warrants: [{
                    object_type: Permission::OBJECT_TYPE,
                    object_id: params[:permission_id],
                    relation: "member",
                    subject: {
                        object_type: User::OBJECT_TYPE,
                        object_id: params[:user_id]
                    },
                    context: params[:context]
                }],
                debug: params[:debug]
            )
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
        def self.has_feature?(params = {})
            return is_authorized?(
                warrants: [{
                    object_type: Feature::OBJECT_TYPE,
                    object_id: params[:feature_id],
                    relation: "member",
                    subject: {
                        object_type: params[:subject][:object_type],
                        object_id: params[:subject][:object_id]
                    },
                    context: params[:context]
                }],
                debug: params[:debug]
            )
        end

        private

        def self.authorize?(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v2/authorize"), Util.normalize_params(params))
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

        def self.edge_authorize?(params = {})
            request_url = URI.parse("#{::Warrant.config.authorize_endpoint}/v2/authorize")
            res = APIOperations.post(request_url, Util.normalize_params(params))
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
