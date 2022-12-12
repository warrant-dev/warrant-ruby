# frozen_string_literal: true

module Warrant
    class Subject
        attr_reader :object_type, :object_id, :relation

        def initialize(object_type, object_id, relation = nil)
            @object_type = object_type
            @object_id = object_id
            @relation = relation
        end

        def self.new_from_hash(attributes)
            object_type = attributes.fetch(:object_type)
            object_id = attributes.fetch(:object_id)
            relation = attributes.fetch(:relation, nil)

            self.new(object_type, object_id, relation)
        end
    end
end
