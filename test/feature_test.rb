# frozen_string_literal: true

require "test_helper"

class FeatureTest < Minitest::Test
    def test_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/features")
            .with(body: "{\"featureId\":\"feature-1\"}")
            .to_return(body: '{"featureId": "feature-1"}')

        created_pricing_tier = Warrant::Feature.create(feature_id: "feature-1")

        assert_equal "feature-1", created_pricing_tier.feature_id
    end

    def test_delete
        stub_request(:delete, "#{Warrant.config.api_base}/v1/features/basic")

        assert_nil Warrant::Feature.delete("basic")
    end

    def test_list
        stub_request(:get, "#{Warrant.config.api_base}/v1/features")
            .to_return(body: '[{"featureId": "feature-1"}, {"featureId": "feature-2"}]')

        features = Warrant::Feature.list

        assert_equal 2, features.length
        assert_equal "feature-1", features[0].feature_id
        assert_equal "feature-2", features[1].feature_id
    end

    def test_get
        stub_request(:get, "#{Warrant.config.api_base}/v1/features/some-feature")
            .to_return(body: '{"featureId": "some-feature"}')

        feature = Warrant::Feature.get("some-feature")

        assert_equal "some-feature", feature.feature_id
    end

    def test_list_for_tenant
        stub_request(:get, "#{Warrant.config.api_base}/v1/tenants/tenant-1/features")
            .to_return(body: '[{"featureId": "basic"}, {"featureId": "pro"}]')

        features = Warrant::Feature.list_for_tenant("tenant-1")

        assert_equal 2, features.length
        assert_equal "basic", features[0].feature_id
        assert_equal "pro", features[1].feature_id
    end

    def test_assign_to_tenant
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "feature", "objectId": "feature-1", "relation": "member", "subject": {"objectType": "tenant", "objectId": "tenant-1"}}')

        assigned_feature = Warrant::Feature.assign_to_tenant("tenant-1", "feature-1")

        assert_equal "feature", assigned_feature.object_type
        assert_equal "feature-1", assigned_feature.object_id
        assert_equal "member", assigned_feature.relation
        assert_equal "tenant", assigned_feature.subject.object_type
        assert_equal "tenant-1", assigned_feature.subject.object_id
    end

    def test_remove_from_tenant
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::Feature.remove_from_tenant("tenant-1", "feature-1")
    end

    def test_list_for_user
        stub_request(:get, "#{Warrant.config.api_base}/v1/users/user-1/features")
            .to_return(body: '[{"featureId": "feature-1"}, {"featureId": "feature-2"}]')

        features = Warrant::Feature.list_for_user("user-1")

        assert_equal 2, features.length
        assert_equal "feature-1", features[0].feature_id
        assert_equal "feature-2", features[1].feature_id
    end

    def test_assign_to_user
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "feature", "objectId": "feature-1", "relation": "member", "subject": {"objectType": "user", "objectId": "user-1"}}')

        assigned_feature = Warrant::Feature.assign_to_user("user-1", "feature-1")

        assert_equal "feature", assigned_feature.object_type
        assert_equal "feature-1", assigned_feature.object_id
        assert_equal "member", assigned_feature.relation
        assert_equal "user", assigned_feature.subject.object_type
        assert_equal "user-1", assigned_feature.subject.object_id
    end

    def test_remove_from_user
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::Feature.remove_from_user("user-1", "some-feature")
    end

    def test_list_for_pricing_tier
        stub_request(:get, "#{Warrant.config.api_base}/v1/pricing-tiers/enterprise/features")
            .to_return(body: '[{"featureId": "feature-1"}, {"featureId": "feature-2"}]')

        features = Warrant::Feature.list_for_pricing_tier("enterprise")

        assert_equal 2, features.length
        assert_equal "feature-1", features[0].feature_id
        assert_equal "feature-2", features[1].feature_id
    end

    def test_assign_to_pricing_tier
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "feature", "objectId": "feature-1", "relation": "member", "subject": {"objectType": "pricing-tier", "objectId": "enterprise"}}')

        assigned_feature = Warrant::Feature.assign_to_pricing_tier("enterprise", "feature-1")

        assert_equal "feature", assigned_feature.object_type
        assert_equal "feature-1", assigned_feature.object_id
        assert_equal "member", assigned_feature.relation
        assert_equal "pricing-tier", assigned_feature.subject.object_type
        assert_equal "enterprise", assigned_feature.subject.object_id
    end

    def test_remove_from_pricing_tier
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::Feature.remove_from_pricing_tier("enterprise", "some-feature")
    end
end
