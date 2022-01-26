# frozen_string_literal: true

module Warrant
    class User
        attr_reader :tenant_id, :user_id, :email

        def initialize(tenant_id, user_id, email)
            @tenant_id = tenant_id
            @user_id = user_id
            @email = email
        end
    end
end
