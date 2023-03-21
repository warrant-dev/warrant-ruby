# frozen_string_literal: true

require "test_helper"

class WarrantTest < Minitest::Test
    def setup
        Warrant.config.use_ssl = true
    end

    def test_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
                .with(body: "{\"objectType\":\"pricing-tier\",\"objectId\":\"enterprise\",\"relation\":\"member\",\"subject\":{\"objectType\":\"user\",\"objectId\":\"11\"}}")
                .to_return(body: '{"objectType": "pricing-tier", "objectId": "enterprise", "relation": "member", "subject": { "objectType": "user", "objectId": "11" }}')

        pricing_tier = OpenStruct.new(warrant_object_type: "pricing-tier", warrant_object_id: "enterprise")
        user = OpenStruct.new(warrant_object_type: "user", warrant_object_id: "11")
        created_warrant = Warrant::Warrant.create(pricing_tier, "member", user)

        assert_equal "pricing-tier", created_warrant.object_type
        assert_equal "enterprise", created_warrant.object_id
        assert_equal "member", created_warrant.relation
        assert_equal "user", created_warrant.subject.object_type
        assert_equal "11", created_warrant.subject.object_id
        assert_nil created_warrant.is_implicit
    end

    def test_delete
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")
                .with(body: "{\"objectType\":\"pricing-tier\",\"objectId\":\"enterprise\",\"relation\":\"member\",\"subject\":{\"objectType\":\"user\",\"objectId\":\"11\"}}")

        pricing_tier = OpenStruct.new(warrant_object_type: "pricing-tier", warrant_object_id: "enterprise")
        user = OpenStruct.new(warrant_object_type: "user", warrant_object_id: "11")
        assert_nil Warrant::Warrant.delete(pricing_tier, "member", user)
    end

    def test_query
        stub_request(:get, "#{Warrant.config.api_base}/v1/query?q=SELECT%20warrant%20FOR%20subject=user:11%20WHERE%20subject=user:11")
        .to_return(body: "{\"result\": [{\"objectType\": \"tenant\", \"objectId\": \"store-1\", \"relation\": \"member\", \"subject\": {\"objectType\": \"user\", \"objectId\": \"8\"}, \"isImplicit\": false}, {\"objectType\": \"feature\", \"objectId\": \"edit-items\", \"relation\": \"member\", \"subject\": {\"objectType\": \"user\", \"objectId\": \"8\"}, \"isImplicit\": true}], \"meta\": {} }")

        warrant_query = Warrant::WarrantQuery.new
        warrant_query.select("warrant").for(subject: "user:11").where(subject: "user:11")
        warrants = Warrant::Warrant.query(warrant_query)

        assert_equal 2, warrants['result'].length

        assert_equal "tenant", warrants['result'][0].object_type
        assert_equal "store-1", warrants['result'][0].object_id
        assert_equal "member", warrants['result'][0].relation
        assert_equal "user", warrants['result'][0].subject.object_type
        assert_equal "8", warrants['result'][0].subject.object_id
        assert_equal false, warrants['result'][0].is_implicit

        assert_equal "feature", warrants['result'][1].object_type
        assert_equal "edit-items", warrants['result'][1].object_id
        assert_equal "member", warrants['result'][1].relation
        assert_equal "user", warrants['result'][1].subject.object_type
        assert_equal "8", warrants['result'][1].subject.object_id
        assert_equal true, warrants['result'][1].is_implicit
    end
end
