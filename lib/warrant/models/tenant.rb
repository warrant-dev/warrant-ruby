# frozen_string_literal: true

module Warrant
    class Tenant
        attr_reader :tenant_id

        def initialize(tenant_id)
            @tenant_id = tenant_id
        end
    end
end
