# frozen_string_literal: true

module Warrant
    class Permission
        attr_reader :permission_id

        def initialize(permission_id)
            @permission_id = permission_id
        end
    end
end
