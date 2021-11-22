# frozen_string_literal: true

module Warrant
    class UserWarrant
        attr_reader :object_type, :object_id, :relation, :user

        def initialize(object_type, object_id, relation, user_id)
            @object_type = object_type
            @object_id = object_id
            @relation = relation
            @user = User.new(user_id)
        end
    end
end
