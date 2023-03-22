# frozen_string_literal: true

require "test_helper"

class PricingTierTest < Minitest::Test
    def setup
        Warrant.config.use_ssl = true
    end

    def test_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/pricing-tiers")
            .with(body: "{\"pricingTierId\":\"enterprise\"}")
            .to_return(body: '{"pricingTierId": "enterprise"}')

        created_pricing_tier = Warrant::PricingTier.create(pricing_tier_id: "enterprise")

        assert_equal "enterprise", created_pricing_tier.pricing_tier_id
    end

    def test_delete
        stub_request(:delete, "#{Warrant.config.api_base}/v1/pricing-tiers/basic")

        assert_nil Warrant::PricingTier.delete("basic")
    end

    def test_list
        stub_request(:get, "#{Warrant.config.api_base}/v1/pricing-tiers")
            .to_return(body: '[{"pricingTierId": "basic"}, {"pricingTierId": "enterprise"}]')

        pricing_tiers = Warrant::PricingTier.list

        assert_equal 2, pricing_tiers.length
        assert_equal "basic", pricing_tiers[0].pricing_tier_id
        assert_equal "enterprise", pricing_tiers[1].pricing_tier_id
    end

    def test_get
        stub_request(:get, "#{Warrant.config.api_base}/v1/pricing-tiers/basic")
            .to_return(body: '{"pricingTierId": "basic"}')

        pricing_tier = Warrant::PricingTier.get("basic")

        assert_equal "basic", pricing_tier.pricing_tier_id
    end

    def test_list_for_tenant
        stub_request(:get, "#{Warrant.config.api_base}/v1/tenants/tenant-1/pricing-tiers")
            .to_return(body: '[{"pricingTierId": "basic"}, {"pricingTierId": "pro"}]')

        pricing_tiers = Warrant::PricingTier.list_for_tenant("tenant-1")

        assert_equal 2, pricing_tiers.length
        assert_equal "basic", pricing_tiers[0].pricing_tier_id
        assert_equal "pro", pricing_tiers[1].pricing_tier_id
    end

    def test_assign_to_tenant
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "pricing-tier", "objectId": "enterprise", "relation": "member", "subject": {"objectType": "tenant", "objectId": "tenant-1"}}')

        assigned_pricing_tier = Warrant::PricingTier.assign_to_tenant("tenant-1", "enterprise")

        assert_equal "pricing-tier", assigned_pricing_tier.object_type
        assert_equal "enterprise", assigned_pricing_tier.object_id
        assert_equal "member", assigned_pricing_tier.relation
        assert_equal "tenant", assigned_pricing_tier.subject.object_type
        assert_equal "tenant-1", assigned_pricing_tier.subject.object_id
    end

    def test_remove_from_tenant
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::PricingTier.remove_from_tenant("tenant-1", "enterprise")
    end

    def test_list_for_user
        stub_request(:get, "#{Warrant.config.api_base}/v1/users/user-1/pricing-tiers")
            .to_return(body: '[{"pricingTierId": "basic"}, {"pricingTierId": "pro"}]')

        pricing_tiers = Warrant::PricingTier.list_for_user("user-1")

        assert_equal 2, pricing_tiers.length
        assert_equal "basic", pricing_tiers[0].pricing_tier_id
        assert_equal "pro", pricing_tiers[1].pricing_tier_id
    end

    def test_assign_to_user
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "pricing-tier", "objectId": "basic", "relation": "member", "subject": {"objectType": "user", "objectId": "user-1"}}')

        assigned_pricing_tier = Warrant::PricingTier.assign_to_user("user-1", "basic")

        assert_equal "pricing-tier", assigned_pricing_tier.object_type
        assert_equal "basic", assigned_pricing_tier.object_id
        assert_equal "member", assigned_pricing_tier.relation
        assert_equal "user", assigned_pricing_tier.subject.object_type
        assert_equal "user-1", assigned_pricing_tier.subject.object_id
    end

    def test_remove_from_user
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::PricingTier.remove_from_user("user-1", "basic")
    end
end
