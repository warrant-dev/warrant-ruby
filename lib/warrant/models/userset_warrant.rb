# frozen_string_literal: true

module Warrant
    class UsersetWarrant
        attr_reader :id, :object_type, :object_id, :relation, :user

        def initialize(id, object_type, object_id, relation, user)
            @id = id
            @object_type = object_type
            @object_id = object_id
            @relation = relation
            @user = Userset.new(user['objectType'], user['objectId'], user['relation'])
        end
    end
end
