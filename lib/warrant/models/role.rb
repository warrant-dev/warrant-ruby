# frozen_string_literal: true

module Warrant
    class Role
        attr_reader :role_id

        def initialize(role_id)
            @role_id = role_id
        end
    end
end
