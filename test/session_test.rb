# frozen_string_literal: true

require "test_helper"

class SessionTest < Minitest::Test
    def setup
        Warrant.config.use_ssl = false
    end

    def test_create_authorization_session
        stub_request(:post, "#{Warrant.config.api_base}/v1/sessions")
            .with(body: "{\"userId\":\"10\",\"type\":\"sess\"}")
            .to_return(body: '{"token": "aj92rn3anra8af!@"}')

        session_token = Warrant::Session.create_authorization_session(user_id: "10")

        assert_equal "aj92rn3anra8af!@", session_token
    end

    def test_create_self_service_session
        stub_request(:post, "#{Warrant.config.api_base}/v1/sessions")
            .with(body: "{\"userId\":\"10\",\"tenantId\":\"2\",\"selfServiceStrategy\":\"rbac\",\"type\":\"ssdash\"}")
            .to_return(body: '{"token": "aj92rn3anra8af!@"}')

        session_url = Warrant::Session.create_self_service_session("www.myapp.com/home", user_id: "10", tenant_id: "2", self_service_strategy: "rbac")

        assert_equal "#{::Warrant.config.self_service_dash_url_base}/aj92rn3anra8af!@?redirectUrl=www.myapp.com/home", session_url
    end
end
