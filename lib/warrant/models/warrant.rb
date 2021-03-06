# frozen_string_literal: true

module Warrant
    class Warrant
        attr_reader :id, :object_type, :object_id, :relation, :subject

        # @!visibility private
        def initialize(object_type, object_id, relation, subject)
            @object_type = object_type
            @object_id = object_id
            @relation = relation
            @subject = subject
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
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.create(params = {})
            res = APIOperations.post(URI.parse("#{::Warrant.config.api_base}/v1/warrants"), Util.normalize_params(params))
            res_json = JSON.parse(res.body)

            case res
            when Net::HTTPSuccess
                subject = Subject.new(res_json['subject']['objectType'], res_json['subject']['objectId'])
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
        # @raise [Warrant::InvalidParameterError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
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

        # List all warrants for your organization.
        #
        # @option filters [String] :object_type The type of object. Must be one of your system's existing object types. (optional)
        # @option filters [String] :object_id The id of the specific object. (optional)
        # @option filters [String] :relation The relation for this object to subject association. The relation must be valid as per the object type definition. (optional)
        #
        # @return [Array<Warrant>] list of all warrants with provided filters
        #
        # @raise [Warrant::InternalError]
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
        def self.list(filters = {})
            res = APIOperations.get(URI.parse("#{::Warrant.config.api_base}/v1/warrants"), filters)

            case res
            when Net::HTTPSuccess
                warrants = JSON.parse(res.body)
                warrants.map{ |warrant|
                    subject = Subject.new(warrant['subject']['objectType'], warrant['subject']['objectId'])
                    Warrant.new(warrant['objectType'], warrant['objectId'], warrant['relation'], subject)
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
        # @param consistentRead [Boolean] Boolean flag indicating whether or not to enforce strict consistency for this access check. Defaults to false. (optional)
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
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
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
        # @raise [Warrant::InvalidRequestError]
        # @raise [Warrant::MissingRequiredParameterError]
        # @raise [Warrant::NotFoundError]
        # @raise [Warrant::UnauthorizedError]
        # @raise [Warrant::WarrantError]
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
