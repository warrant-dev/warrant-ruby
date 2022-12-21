# frozen_string_literal: true

require "test_helper"

class LiveTest < Minitest::Test
    def setup
        Warrant.api_key = "YOUR_KEY"
        WebMock.allow_net_connect!
    end

    def test_crud_users
        user1 = Warrant::User.create
        assert user1.user_id
        assert_nil user1.email

        user2 = Warrant::User.create(user_id: "my-ruby-user-1", email: "email@test.com")
        fetched_user = Warrant::User.get(user2.user_id)
        assert_equal "my-ruby-user-1", fetched_user.user_id
        assert_equal "email@test.com", fetched_user.email

        updated_user = fetched_user.update(email: "updated@email.com")
        assert_equal "my-ruby-user-1", updated_user.user_id
        assert_equal "updated@email.com", updated_user.email

        users = Warrant::User.list(limit: 10, page: 1)
        assert_equal 2, users.length

        Warrant::User.delete(user1.user_id)
        Warrant::User.delete(user2.user_id)
        users = Warrant::User.list(limit: 10, page: 1)
        assert_equal 0, users.length
    end

    def test_crud_tenants
        tenant1 = Warrant::Tenant.create
        assert tenant1.tenant_id
        assert_nil tenant1.name

        tenant2 = Warrant::Tenant.create(tenant_id: "my-ruby-tenant-1", name: "My Tenant")
        fetched_tenant = Warrant::Tenant.get(tenant2.tenant_id)
        assert_equal "my-ruby-tenant-1", fetched_tenant.tenant_id
        assert_equal "My Tenant", fetched_tenant.name

        updated_tenant = fetched_tenant.update(name: "Updated Tenant")
        assert_equal "my-ruby-tenant-1", updated_tenant.tenant_id
        assert_equal "Updated Tenant", updated_tenant.name

        tenants = Warrant::Tenant.list(limit: 10, page: 1)
        assert_equal 2, tenants.length

        Warrant::Tenant.delete(tenant1.tenant_id)
        Warrant::Tenant.delete(tenant2.tenant_id)
        tenants = Warrant::Tenant.list(limit: 10, page: 1)
        assert_equal 0, tenants.length
    end

    def test_crud_roles
        current_roles = Warrant::Role.list(limit: 10, page: 1)

        role1 = Warrant::Role.create(role_id: "some-role")
        assert_equal "some-role", role1.role_id
        assert_nil role1.name
        assert_nil role1.description

        role2 = Warrant::Role.create(role_id: "some-admin", name: "Admin", description: "Role for administrators")
        fetched_role = Warrant::Role.get(role2.role_id)
        assert_equal "some-admin", fetched_role.role_id
        assert_equal "Admin", fetched_role.name
        assert_equal "Role for administrators", fetched_role.description

        updated_role = fetched_role.update(name: "New Admin", description: "updated admin description")
        assert_equal "some-admin", updated_role.role_id
        assert_equal "New Admin", updated_role.name
        assert_equal "updated admin description", updated_role.description

        roles = Warrant::Role.list(limit: 10, page: 1)
        assert_equal current_roles.length + 2, roles.length

        Warrant::Role.delete(role1.role_id)
        Warrant::Role.delete(role2.role_id)
        roles = Warrant::Role.list(limit: 10, page: 1)
        assert_equal current_roles.length, roles.length
    end

    def test_crud_permissions
        current_permissions = Warrant::Permission.list(limit: 10, page: 1)

        permission1 = Warrant::Permission.create(permission_id: "permission-1")
        assert_equal "permission-1", permission1.permission_id
        assert_nil permission1.name
        assert_nil permission1.description

        permission2 = Warrant::Permission.create(permission_id: "some-permission", name: "Some Permission", description: "A Permission")
        fetched_permission = Warrant::Permission.get(permission2.permission_id)
        assert_equal "some-permission", fetched_permission.permission_id
        assert_equal "Some Permission", fetched_permission.name
        assert_equal "A Permission", fetched_permission.description

        updated_permission = fetched_permission.update(name: "Updated Permission", description: "updated permission description")
        assert_equal "some-permission", updated_permission.permission_id
        assert_equal "Updated Permission", updated_permission.name
        assert_equal "updated permission description", updated_permission.description

        permissions = Warrant::Permission.list(limit: 10, page: 1)
        assert_equal current_permissions.length + 2, permissions.length

        Warrant::Permission.delete(permission1.permission_id)
        Warrant::Permission.delete(permission2.permission_id)
        permissions = Warrant::Permission.list(limit: 10, page: 1)
        assert_equal current_permissions.length, permissions.length
    end

    def test_crud_pricing_tiers
        pricing_tier1 = Warrant::PricingTier.create(pricing_tier_id: "enterprise")
        assert_equal "enterprise", pricing_tier1.pricing_tier_id

        pricing_tier2 = Warrant::PricingTier.create(pricing_tier_id: "basic", name: "Basic", description: "Basic pricing plan")
        fetched_pricing_tier = Warrant::PricingTier.get(pricing_tier2.pricing_tier_id)
        assert_equal "basic", fetched_pricing_tier.pricing_tier_id

        pricing_tiers = Warrant::PricingTier.list(limit: 10, page: 1)
        assert_equal 2, pricing_tiers.length

        Warrant::PricingTier.delete(pricing_tier1.pricing_tier_id)
        Warrant::PricingTier.delete(pricing_tier2.pricing_tier_id)
        pricing_tiers = Warrant::PricingTier.list(limit: 10, page: 1)
        assert_equal 0, pricing_tiers.length
    end

    def test_crud_features
        feature1 = Warrant::Feature.create(feature_id: "reports")
        assert_equal "reports", feature1.feature_id

        feature2 = Warrant::Feature.create(feature_id: "some-feature")
        fetched_feature = Warrant::Feature.get(feature2.feature_id)
        assert_equal "some-feature", fetched_feature.feature_id

        features = Warrant::Feature.list(limit: 10, page: 1)
        assert_equal 2, features.length

        Warrant::Feature.delete(feature1.feature_id)
        Warrant::Feature.delete(feature2.feature_id)
        features = Warrant::Feature.list(limit: 10, page: 1)
        assert_equal 0, features.length
    end

    def test_batch_create_users_and_tenants
        created_users = Warrant::User.batch_create([
            { user_id: "user-1" },
            { user_id: "user-2", email: "user2@test.com" },
            { user_id: "user-3", email: "user3@test.com" },
        ])

        assert_equal 3, created_users.length
        assert_equal "user-1", created_users[0].user_id
        assert_equal "user-2", created_users[1].user_id
        assert_equal "user-3", created_users[2].user_id

        created_tenants = Warrant::Tenant.batch_create([
            { tenant_id: "tenant-1" },
            { tenant_id: "tenant-2", name: "Tenant 2" },
            { tenant_id: "tenant-3", name: "Tenant 3" },
        ])

        assert_equal 3, created_tenants.length
        assert_equal "tenant-1", created_tenants[0].tenant_id
        assert_equal "tenant-2", created_tenants[1].tenant_id
        assert_equal "tenant-3", created_tenants[2].tenant_id

        Warrant::User.delete("user-1")
        Warrant::User.delete("user-2")
        Warrant::User.delete("user-3")
        Warrant::Tenant.delete("tenant-1")
        Warrant::Tenant.delete("tenant-2")
        Warrant::Tenant.delete("tenant-3")
    end

    def test_multitenancy
        user1 = Warrant::User.create
        user2 = Warrant::User.create

        tenant1 = Warrant::Tenant.create
        tenant2 = Warrant::Tenant.create

        user1_tenants = user1.list_tenants
        assert_equal 0, user1_tenants.length

        tenant1_users = tenant1.list_users
        assert_equal 0, tenant1_users.length

        tenant1.add_user(user1.user_id)

        user1_tenants = user1.list_tenants
        assert_equal 1, user1_tenants.length
        assert_equal tenant1.tenant_id, user1_tenants[0].tenant_id

        tenant1_users = tenant1.list_users
        assert_equal 1, tenant1_users.length
        assert_equal user1.user_id, tenant1_users[0].user_id

        tenant1.remove_user(user1.user_id)

        user1_tenants = user1.list_tenants
        assert_equal 0, user1_tenants.length

        tenant1_users = tenant1.list_users
        assert_equal 0, tenant1_users.length

        Warrant::User.delete(user1.user_id)
        Warrant::User.delete(user2.user_id)
        Warrant::Tenant.delete(tenant1.tenant_id)
        Warrant::Tenant.delete(tenant2.tenant_id)
    end

    def test_rbac
        admin_user = Warrant::User.create
        viewer_user = Warrant::User.create

        admin_role = Warrant::Role.create(role_id: "administrator", name: "Admin", description: "Admin role")
        viewer_role = Warrant::Role.create(role_id: "viewer", name: "Viewer", description: "Viewer role")

        create_permission = Warrant::Permission.create(permission_id: "create-report", name: "Create Report", description: "Permission to create reports")
        view_permission = Warrant::Permission.create(permission_id: "view-report", name: "View Report", description: "Permission to view reports")

        # Assign create-report permission to admin role and admin user
        assert_equal 0, admin_user.list_roles.length
        assert_equal 0, admin_role.list_permissions.length
        assert_equal false, admin_user.has_permission?(create_permission.permission_id)

        admin_role.assign_permission(create_permission.permission_id)
        admin_user.assign_role(admin_role.role_id)

        admin_role_permissions = admin_role.list_permissions(page: 1, limit: 100)
        assert_equal 1, admin_role_permissions.length
        assert_equal "create-report", admin_role_permissions[0].permission_id
        assert_equal true, admin_user.has_permission?("create-report")

        admin_user_roles = admin_user.list_roles(page: 1, limit: 100)
        assert_equal 1, admin_user_roles.length
        assert_equal "administrator", admin_user_roles[0].role_id

        Warrant::Permission.remove_from_role("administrator", "create-report")

        assert_equal false, Warrant::Warrant.user_has_permission?(user_id: admin_user.user_id, permission_id: "create-report")
        assert_equal 1, admin_user.list_roles.length

        Warrant::Role.remove_from_user(admin_user.user_id, admin_role.role_id)

        assert_equal 0, admin_user.list_roles.length

        # Assign view-report to viewer user
        assert_equal 0, viewer_user.list_permissions.length
        assert_equal false, viewer_user.has_permission?("view-report")

        Warrant::Permission.assign_to_user(viewer_user.user_id, view_permission.permission_id)

        assert_equal true, Warrant::Warrant.user_has_permission?(user_id: viewer_user.user_id, permission_id: view_permission.permission_id)

        viewer_user_permissions = Warrant::Permission.list_for_user(viewer_user.user_id, page: 1, limit: 100)

        assert_equal 1, viewer_user_permissions.length
        assert_equal "view-report", viewer_user_permissions[0].permission_id

        viewer_user.remove_permission(view_permission.permission_id)

        assert_equal 0, viewer_user.list_permissions.length
        assert_equal false, viewer_user.has_permission?("view-report")

        Warrant::User.delete(admin_user.user_id)
        Warrant::User.delete(viewer_user.user_id)
        Warrant::Role.delete(admin_role.role_id)
        Warrant::Role.delete(viewer_role.role_id)
        Warrant::Permission.delete(create_permission.permission_id)
        Warrant::Permission.delete(view_permission.permission_id)
    end

    def test_pricing_tiers_and_features_users
        # Create users
        free_user = Warrant::User.create
        paid_user = Warrant::User.create

        # Create pricing tiers
        free_tier = Warrant::PricingTier.create(pricing_tier_id: "free")
        paid_tier = Warrant::PricingTier.create(pricing_tier_id: "paid")

        # Create features
        custom_feature = Warrant::Feature.create(feature_id: "custom-feature")
        feature1 = Warrant::Feature.create(feature_id: "feature-1")
        feature2 = Warrant::Feature.create(feature_id: "feature-2")

        # Assign custom-feature to paid user
        assert_equal false, paid_user.has_feature?("custom-feature")
        assert_equal 0, paid_user.list_features(page: 1, limit: 100).length

        paid_user.assign_feature(custom_feature.feature_id)

        assert_equal true, paid_user.has_feature?("custom-feature")

        paid_user_features = Warrant::Feature.list_for_user(paid_user.user_id, page: 1, limit: 100)

        assert_equal 1, paid_user_features.length
        assert_equal "custom-feature", paid_user_features[0].feature_id

        Warrant::Feature.remove_from_user(paid_user.user_id, custom_feature.feature_id)

        assert_equal false, paid_user.has_feature?("custom-feature")
        assert_equal 0, paid_user.list_features.length

        # Assign feature-1 to free tier to free user
        assert_equal false, free_user.has_feature?("feature-1")
        assert_equal 0, Warrant::Feature.list_for_pricing_tier(free_tier.pricing_tier_id, page: 1, limit: 100).length
        assert_equal 0, Warrant::PricingTier.list_for_user(free_user.user_id, page: 1, limit: 100).length

        Warrant::Feature.assign_to_pricing_tier(free_tier.pricing_tier_id, feature1.feature_id)
        Warrant::PricingTier.assign_to_user(free_user.user_id, free_tier.pricing_tier_id)

        assert_equal true, free_user.has_feature?("feature-1")

        free_tier_features = free_tier.list_features

        assert_equal 1, free_tier_features.length
        assert_equal "feature-1", free_tier_features[0].feature_id

        free_user_tiers = free_user.list_pricing_tiers

        assert_equal 1, free_user_tiers.length
        assert_equal "free", free_user_tiers[0].pricing_tier_id

        free_tier.remove_feature(feature1.feature_id)

        assert_equal false, free_user.has_feature?("feature-1")
        assert_equal 0, free_tier.list_features.length
        assert_equal 1, free_user.list_pricing_tiers.length

        free_user.remove_pricing_tier(free_tier.pricing_tier_id)

        assert_equal 0, free_user.list_pricing_tiers.length

        # Clean up
        Warrant::User.delete(free_user.user_id)
        Warrant::User.delete(paid_user.user_id)
        Warrant::PricingTier.delete(free_tier.pricing_tier_id)
        Warrant::PricingTier.delete(paid_tier.pricing_tier_id)
        Warrant::Feature.delete(custom_feature.feature_id)
        Warrant::Feature.delete(feature1.feature_id)
        Warrant::Feature.delete(feature2.feature_id)
    end

    def test_pricing_tiers_and_features_tenants
        # Create tenants
        free_tenant = Warrant::Tenant.create
        paid_tenant = Warrant::Tenant.create

        # Create pricing tiers
        free_tier = Warrant::PricingTier.create(pricing_tier_id: "free")
        paid_tier = Warrant::PricingTier.create(pricing_tier_id: "paid")

        # Create features
        custom_feature = Warrant::Feature.create(feature_id: "custom-feature")
        feature1 = Warrant::Feature.create(feature_id: "feature-1")
        feature2 = Warrant::Feature.create(feature_id: "feature-2")

        # Assign custom-feature to paid tenant
        assert_equal false, paid_tenant.has_feature?("custom-feature")
        assert_equal 0, paid_tenant.list_features.length

        paid_tenant.assign_feature(custom_feature.feature_id)

        assert_equal true, paid_tenant.has_feature?(custom_feature.feature_id)

        paid_tenant_features = paid_tenant.list_features

        assert_equal 1, paid_tenant_features.length
        assert_equal "custom-feature", paid_tenant_features[0].feature_id

        Warrant::Feature.remove_from_tenant(paid_tenant.tenant_id, custom_feature.feature_id)

        assert_equal false, Warrant::Warrant.has_feature?(subject: { object_type: "tenant", object_id: paid_tenant.tenant_id }, feature_id: "custom-feature")
        assert_equal 0, paid_tenant.list_features.length

        # Assign feature-1 to free tier to free tenant
        assert_equal false, free_tenant.has_feature?("feature-1")
        assert_equal 0, free_tier.list_features(page: 1, limit: 100).length
        assert_equal 0, free_tenant.list_pricing_tiers(page: 1, limit: 100).length

        free_tier.assign_feature(feature1.feature_id)
        free_tenant.assign_pricing_tier(free_tier.pricing_tier_id)

        assert_equal true, free_tenant.has_feature?("feature-1")

        free_tier_features = Warrant::Feature.list_for_pricing_tier(free_tier.pricing_tier_id, page: 1, limit: 100)

        assert_equal 1, free_tier_features.length
        assert_equal "feature-1", free_tier_features[0].feature_id

        free_tenant_tiers = Warrant::PricingTier.list_for_tenant(free_tenant.tenant_id, page: 1, limit: 100)

        assert_equal 1, free_tenant_tiers.length
        assert_equal "free", free_tenant_tiers[0].pricing_tier_id

        free_tier.remove_feature(feature1.feature_id)

        assert_equal false, free_tenant.has_feature?("feature-1")
        assert_equal 0, free_tier.list_features(page: 1, limit: 100).length
        assert_equal 1, free_tenant.list_pricing_tiers(page: 1, limit: 100).length

        free_tenant.remove_pricing_tier(free_tier.pricing_tier_id)

        assert_equal 0, free_tenant.list_pricing_tiers(page: 1, limit: 100).length

        # Clean up
        Warrant::Tenant.delete(free_tenant.tenant_id)
        Warrant::Tenant.delete(paid_tenant.tenant_id)
        Warrant::PricingTier.delete(free_tier.pricing_tier_id)
        Warrant::PricingTier.delete(paid_tier.pricing_tier_id)
        Warrant::Feature.delete(custom_feature.feature_id)
        Warrant::Feature.delete(feature1.feature_id)
        Warrant::Feature.delete(feature2.feature_id)
    end

    def test_sessions
        user = Warrant::User.create
        tenant = Warrant::Tenant.create

        Warrant::User.add_to_tenant(tenant.tenant_id, user.user_id)
        Warrant::Permission.assign_to_user(user.user_id, "view-self-service-dashboard")

        assert Warrant::Session.create_authorization_session(user_id: user.user_id)
        assert Warrant::Session.create_self_service_session("http://localhost:8080", user_id: user.user_id, tenant_id: tenant.tenant_id)

        Warrant::User.delete(user.user_id)
        Warrant::Tenant.delete(tenant.tenant_id)
    end

    def test_warrants
        new_user = Warrant::User.create
        new_permission = Warrant::Permission.create(permission_id: "permission-1", name: "Permission 1", description: "some permission")

        assert_equal false, Warrant::Warrant.check(new_permission, "member", new_user)

        Warrant::Warrant.create(
            object_type: "permission",
            object_id: new_permission.permission_id,
            relation: "member",
            subject: {
                object_type: "user",
                object_id: new_user.user_id
            }
        )

        assert_equal true, Warrant::Warrant.check(new_permission, "member", new_user)

        query_warrants = Warrant::Warrant.query(subject: { object_type: "user", object_id: new_user.user_id }, page: 1, limit: 100)

        assert_equal 1, query_warrants.length
        assert_equal "permission", query_warrants[0].object_type
        assert_equal "permission-1", query_warrants[0].object_id
        assert_equal "member", query_warrants[0].relation

        Warrant::Warrant.delete(
            object_type: "permission",
            object_id: new_permission.permission_id,
            relation: "member",
            subject: {
                object_type: "user",
                object_id: new_user.user_id
            }
        )

        assert_equal false, Warrant::Warrant.check(new_permission, "member", new_user)

        Warrant::User.delete(new_user.user_id)
        Warrant::Permission.delete(new_permission.permission_id)
    end
end
