# frozen_string_literal: true

module Warrant
    class Userset
        attr_reader :object_type, :object_id, :relation

        def initialize(object_type, object_id, relation)
            @object_type = object_type
            @object_id = object_id
            @relation = relation
        end
    end
end
