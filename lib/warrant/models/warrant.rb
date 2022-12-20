# frozen_string_literal: true

module Warrant
    class Warrant
        attr_reader :id, :object_type, :object_id, :relation, :subject, :is_direct_match

        # @!visibility private
        def initialize(object_type, object_id, relation, subject, is_direct_match = nil)
            @object_type = object_type
            @object_id = object_id
            @relation = relation
            @subject = subject
            @is_direct_match = is_direct_match
        end

        # Create a new warrant that associates an object (object_type and object_id) to a subject via a relation.
        #
        # @option params [String] :object_type The type of object. Must be one of your system's existing object types.
        # @option params [String] :object_id The id of the specific object.
        # @option params [String] :relation The relation for this object to subject association. The relation must be valid as per the object type definition.
        # @option params [Hash] :subject The specific subject (object, user etc.) to be associated with the object. A subject can either be a specific object (by id) or a group of objects defined by a set containing an objectType, objectId and relation.
        #   * :object_type (String) - The type of object. Must be one of your system's existing object types.
        #   * :object_id (String) - The id of the specific object.
        #   * :relation (String) - The relation for this object to subject association. The relation must be valid as per the object type definition. (optional)
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
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/warrants"), Util.normalize_params(params))
            res_json = JSON.parse(res.body)

            case res
            when Net::HTTPSuccess
                subject = Subject.new(res_json['subject']['objectType'], res_json['subject']['objectId'], res_json['subject']['relation'])
                Warrant.new(res_json['objectType'], res_json['objectId'], res_json['relation'], subject)
            else
                APIOperations.raise_error(res)
            end
        end

        # Deletes a warrant specified by the combination of object_type, object_id, relation, and subject.
        #
        # @option params [String] :object_type The type of object. Must be one of your system's existing object types.
        # @option params [String] :object_id The id of the specific object.
        # @option params [String] :relation The relation for this object to subject association. The relation must be valid as per the object type definition.
        # @option params [Hash] :subject The specific subject (object, user etc.) to be associated with the object. A subject can either be a specific object (by id) or a group of objects defined by a set containing an objectType, objectId and relation.
        #   * :object_type [String] The type of object. Must be one of your system's existing object types.
        #   * :object_id [String] The id of the specific object.
        #   * :relation [String] The relation for this object to subject association. The relation must be valid as per the object type definition. (optional)
        #
        # @return [nil] if delete was successful
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.delete(params = {})
            res = APIOperations.delete(URI.parse("#{::Warrant.config.api_base}/v1/warrants"), Util.normalize_params(params))

            case res
            when Net::HTTPSuccess
                return
            else
                APIOperations.raise_error(res)
            end
        end

        # Query to find all warrants for a given subject.
        #
        # @option params [String] :object_type The type of object. Must be one of your system's existing object types. (optional)
        # @option params [String] :relation The relation for this object to subject association. The relation must be valid as per the object type definition. (optional)
        # @option params [String] :subject The subject to query warrants for. This should be in the format `OBJECT_TYPE:OBJECT_ID`, i.e. `user:8`
        #   * subject (Hash) - The specific subject for which warrants will be queried for.
        #       * object_type (String) - The type of object. Must be one of your system's existing object types.
        #       * object_id (String) - The id of the specific object.
        # @option params [Integer] :page A positive integer (starting with 1) representing the page of items to return in response. Used in conjunction with the limit param. (optional)
        # @option params [Integer] :limit A positive integer representing the max number of items to return in response. (optional)
        #
        # @return [Array<Warrant>] list of all warrants with provided params
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.query(params = {})
            params[:subject] = Subject.new_from_hash(params[:subject])
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/query"), params)

            case res
            when Net::HTTPSuccess
                warrants = JSON.parse(res.body)
                warrants.map{ |warrant|
                    subject = Subject.new(warrant['subject']['objectType'], warrant['subject']['objectId'], warrant['subject']['relation'])
                    Warrant.new(warrant['objectType'], warrant['objectId'], warrant['relation'], subject, warrant['isDirectMatch'])
                }
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
        # @param consistent_read [Boolean] Boolean flag indicating whether or not to enforce strict consistency for this access check. Defaults to false. (optional)
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

        # Checks whether a given user has a given permission.
        #
        # @param user_id [String] Id of the user to check
        # @param permission_id [String] Id of the permission to check on the user
        # @param consistentRead [Boolean] Boolean flag indicating whether or not to enforce strict consistency for this access check. Defaults to false. (optional)
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
                    object_type: "permission",
                    object_id: params[:permission_id],
                    relation: "member",
                    subject: {
                        object_type: "user",
                        object_id: params[:user_id]
                    }
                }],
                consistentRead: params[:consistentRead],
                debug: params[:debug]
            )
        end

        # Checks whether a given subject has a given feature.
        #
        # @param subject (Hash) - The specific subject for which feature access will be checked.
        #   * object_type (String) - The type of object. Must be one of your system's existing object types.
        #   * object_id (String) - The id of the specific object.
        # @param feature_id [String] Id of the feature to check on the subject
        # @param consistent_read [Boolean] Boolean flag indicating whether or not to enforce strict consistency for this access check. Defaults to false. (optional)
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
                    object_type: "feature",
                    object_id: params[:feature_id],
                    relation: "member",
                    subject: {
                        object_type: params[:subject][:object_type],
                        object_id: params[:subject][:object_id]
                    }
                }],
                consistent_read: params[:consistent_read],
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
            res = APIOperations.post(request_url, Util.normalize_params(params), request_url.scheme === "https")
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
