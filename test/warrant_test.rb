# frozen_string_literal: true

require "test_helper"

class WarrantTest < Minitest::Test
  def test_create
    stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .with(body: "{\"objectType\":\"pricing-tier\",\"objectId\":\"enterprise\",\"relation\":\"member\",\"subject\":{\"objectType\":\"user\",\"objectId\":\"11\"},\"context\":null}")
            .to_return(body: '{"objectType": "pricing-tier", "objectId": "enterprise", "relation": "member", "subject": { "objectType": "user", "objectId": "11" }}')

    pricing_tier = OpenStruct.new(warrant_object_type: "pricing-tier", warrant_object_id: "enterprise")
    user = OpenStruct.new(warrant_object_type: "user", warrant_object_id: "11")
    created_warrant = Warrant::Warrant.create(pricing_tier, "member", user)

    assert_equal "pricing-tier", created_warrant.object_type
    assert_equal "enterprise", created_warrant.object_id
    assert_equal "member", created_warrant.relation
    assert_equal "user", created_warrant.subject.object_type
    assert_equal "11", created_warrant.subject.object_id
    assert_nil created_warrant.is_direct_match
  end

  def test_delete
    stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")
            .with(body: "{\"objectType\":\"pricing-tier\",\"objectId\":\"enterprise\",\"relation\":\"member\",\"subject\":{\"objectType\":\"user\",\"objectId\":\"11\"},\"context\":null}")

    pricing_tier = OpenStruct.new(warrant_object_type: "pricing-tier", warrant_object_id: "enterprise")
    user = OpenStruct.new(warrant_object_type: "user", warrant_object_id: "11")
    assert_nil Warrant::Warrant.delete(pricing_tier, "member", user)
  end

  def test_query
    stub_request(:get, "#{Warrant.config.api_base}/v1/query?subject=user:11")
      .to_return(body: '[{"objectType": "tenant", "objectId": "store-1", "relation": "member", "subject": {"objectType": "user", "objectId": "8"}, "isDirectMatch": true}, {"objectType": "feature", "objectId": "edit-items", "relation": "member", "subject": {"objectType": "user", "objectId": "8"}, "isDirectMatch": false}]')

    warrants = Warrant::Warrant.query(subject: { object_type: "user", object_id: "11"})

    assert_equal 2, warrants.length

    assert_equal "tenant", warrants[0].object_type
    assert_equal "store-1", warrants[0].object_id
    assert_equal "member", warrants[0].relation
    assert_equal "user", warrants[0].subject.object_type
    assert_equal "8", warrants[0].subject.object_id
    assert_equal true, warrants[0].is_direct_match

    assert_equal "feature", warrants[1].object_type
    assert_equal "edit-items", warrants[1].object_id
    assert_equal "member", warrants[1].relation
    assert_equal "user", warrants[1].subject.object_type
    assert_equal "8", warrants[1].subject.object_id
    assert_equal false, warrants[1].is_direct_match
  end
end
