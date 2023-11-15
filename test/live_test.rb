# frozen_string_literal: true

require "test_helper"

class LiveTest < Minitest::Test
    def setup
        # Comment out skip() call and add your api key to run tests against the live server
        skip()
        # Uncomment if the endpoint you're testing against is not behind SSL
        # Warrant.use_ssl = false
        Warrant.api_key = ""
        WebMock.allow_net_connect!
    end

    def test_crud_users
        user1 = Warrant::User.create
        assert user1.user_id
        assert_nil user1.meta

        user2 = Warrant::User.create({ user_id: "zz-ruby-user-1", meta: { email: "email@test.com" } })
        fetched_user = Warrant::User.get(user2.user_id, { warrant_token: "latest" })
        assert_equal user2.user_id, fetched_user.user_id
        assert_equal user2.meta, fetched_user.meta

        user2 = fetched_user.update({ email: "updated@email.com" })
        refetched_user = Warrant::User.get(user2.user_id, { warrant_token: "latest" })
        assert_equal "zz-ruby-user-1", user2.user_id
        assert_equal({ email: "updated@email.com" }, user2.meta)

        users = Warrant::User.list({ limit: 10 }, { warrant_token: "latest "})
        assert_equal 2, users.results.length
        assert_equal user1.user_id, users.results[0].user_id
        assert_equal user2.user_id, users.results[1].user_id

        warrant_token = Warrant::User.delete(user1.user_id)
        assert warrant_token
        warrant_token = Warrant::User.delete(user2.user_id)
        assert warrant_token
        users = Warrant::User.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, users.results.length
    end

    def test_batch_create_delete_users
        users = Warrant::User.batch_create([
            { user_id: "user-1" },
            { user_id: "user-2", meta: { email: "user2@test.com" } },
            { user_id: "user-3", meta: { email: "user3@test.com" } },
        ])
        assert_equal 3, users.length

        fetched_users = Warrant::User.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 3, fetched_users.results.length
        assert_equal "user-1", fetched_users.results[0].user_id
        assert_equal "user-2", fetched_users.results[1].user_id
        assert_equal({ email: "user2@test.com" }, fetched_users.results[1].meta)
        assert_equal "user-3", fetched_users.results[2].user_id
        assert_equal({ email: "user3@test.com" }, fetched_users.results[2].meta)

        warrant_token = Warrant::User.batch_delete([
            fetched_users.results[0],
            { user_id: "user-2" },
            { user_id: "user-3" },
        ])
        assert warrant_token

        fetched_users = Warrant::User.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, fetched_users.results.length
    end

    def test_crud_tenants
        tenant1 = Warrant::Tenant.create
        assert tenant1.tenant_id
        assert_nil tenant1.meta

        tenant2 = Warrant::Tenant.create({ tenant_id: "zz-ruby-tenant-1", meta: { name: "My Tenant" } })
        fetched_tenant = Warrant::Tenant.get(tenant2.tenant_id, { warrant_token: "latest" })
        assert_equal tenant2.tenant_id, fetched_tenant.tenant_id
        assert_equal tenant2.meta, fetched_tenant.meta

        tenant2 = fetched_tenant.update({ name: "Updated Tenant" })
        refetched_tenant = Warrant::Tenant.get(tenant2.tenant_id, { warrant_token: "latest" })
        assert_equal "zz-ruby-tenant-1", refetched_tenant.tenant_id
        assert_equal({ name: "Updated Tenant" }, refetched_tenant.meta)

        tenants = Warrant::Tenant.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 2, tenants.results.length
        assert_equal tenant1.tenant_id, tenants.results[0].tenant_id
        assert_equal tenant2.tenant_id, tenants.results[1].tenant_id

        warrant_token = Warrant::Tenant.delete(tenant1.tenant_id)
        assert warrant_token
        warrant_token = Warrant::Tenant.delete(tenant2.tenant_id)
        assert warrant_token
        tenants = Warrant::Tenant.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, tenants.results.length
    end

    def test_batch_create_delete_tenants
        tenants = Warrant::Tenant.batch_create([
            { tenant_id: "tenant-a", meta: { name: "Tenant A" } },
            { tenant_id: "tenant-b" },
            { tenant_id: "tenant-c", meta: { description: "Company C" } },
        ])
        assert_equal 3, tenants.length

        fetched_tenants = Warrant::Tenant.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 3, fetched_tenants.results.length
        assert_equal "tenant-a", fetched_tenants.results[0].tenant_id
        assert_equal({ name: "Tenant A" }, fetched_tenants.results[0].meta)
        assert_equal "tenant-b", fetched_tenants.results[1].tenant_id
        assert_equal "tenant-c", fetched_tenants.results[2].tenant_id
        assert_equal({ description: "Company C" }, fetched_tenants.results[2].meta)

        warrant_token = Warrant::Tenant.batch_delete([
            fetched_tenants.results[0],
            { tenant_id: "tenant-b" },
            { tenant_id: "tenant-c" },
        ])
        assert warrant_token

        fetched_tenants = Warrant::Tenant.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, fetched_tenants.results.length
    end

    def test_crud_roles
        admin_role = Warrant::Role.create({ role_id: "admin", meta: { name: "Admin", description: "The admin role" } })
        assert_equal "admin", admin_role.role_id
        assert_equal({ name: "Admin", description: "The admin role" }, admin_role.meta)

        viewer_role = Warrant::Role.create({ role_id: "viewer", meta: { name: "Viewer", description: "The viewer role" }})
        fetched_role = Warrant::Role.get(viewer_role.role_id, { warrant_token: "latest" })
        assert_equal viewer_role.role_id, fetched_role.role_id
        assert_equal viewer_role.meta, fetched_role.meta

        viewer_role = fetched_role.update({ name: "Viewer Updated", description: "Updated desc" })
        refetched_role = Warrant::Role.get(viewer_role.role_id, { warrant_token: "latest" })
        assert_equal "viewer", refetched_role.role_id
        assert_equal({ name: "Viewer Updated", description: "Updated desc" }, refetched_role.meta)

        roles = Warrant::Role.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 2, roles.results.length
        assert_equal "admin", roles.results[0].role_id
        assert_equal "viewer", roles.results[1].role_id

        warrant_token = Warrant::Role.delete(admin_role.role_id)
        assert warrant_token
        warrant_token = Warrant::Role.delete(viewer_role.role_id)
        assert warrant_token
        roles = Warrant::Role.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, roles.results.length
    end

    def test_crud_permissions
        permission1 = Warrant::Permission.create({ permission_id: "perm1", meta: { name: "Permission 1", description: "Permission with id 1" } })
        assert_equal "perm1", permission1.permission_id
        assert_equal({ name: "Permission 1", description: "Permission with id 1" }, permission1.meta)

        permission2 = Warrant::Permission.create({ permission_id: "perm2", meta: { name: "Some Permission", description: "A Permission" } })
        fetched_permission = Warrant::Permission.get(permission2.permission_id, { warrant_token: "latest" })
        assert_equal permission2.permission_id, fetched_permission.permission_id
        assert_equal permission2.meta, fetched_permission.meta

        permission2 = fetched_permission.update({ name: "Permission 2 Updated", description: "Updated desc" })
        refetched_permission = Warrant::Permission.get(permission2.permission_id, { warrant_token: "latest" })
        assert_equal "perm2", refetched_permission.permission_id
        assert_equal({ name: "Permission 2 Updated", description: "Updated desc" }, refetched_permission.meta)

        permissions = Warrant::Permission.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 2, permissions.results.length
        assert_equal "perm1", permissions.results[0].permission_id
        assert_equal "perm2", permissions.results[1].permission_id

        warrant_token = Warrant::Permission.delete(permission1.permission_id)
        assert warrant_token
        warrant_token = Warrant::Permission.delete(permission2.permission_id)
        assert warrant_token
        permissions = Warrant::Permission.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, permissions.results.length
    end

    def test_crud_pricing_tiers
        tier1 = Warrant::PricingTier.create({ pricing_tier_id: "new-tier-1", meta: { name: "New Pricing Tier" }})
        assert_equal "new-tier-1", tier1.pricing_tier_id
        assert_equal({ name: "New Pricing Tier" }, tier1.meta)

        tier2 = Warrant::PricingTier.create({ pricing_tier_id: "tier-2" })
        fetched_pricing_tier = Warrant::PricingTier.get(tier2.pricing_tier_id, { warrant_token: "latest" })
        assert_equal tier2.pricing_tier_id, fetched_pricing_tier.pricing_tier_id
        assert_equal tier2.meta, fetched_pricing_tier.meta

        tier2 = fetched_pricing_tier.update({ name: "Tier 2", description: "Second pricing tier" })
        fetched_pricing_tier = Warrant::PricingTier.get(tier2.pricing_tier_id, { warrant_token: "latest" })
        assert_equal "tier-2", fetched_pricing_tier.pricing_tier_id
        assert_equal({ name: "Tier 2", description: "Second pricing tier" }, fetched_pricing_tier.meta)

        pricing_tiers = Warrant::PricingTier.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 2, pricing_tiers.results.length
        assert_equal "new-tier-1", pricing_tiers.results[0].pricing_tier_id
        assert_equal "tier-2", pricing_tiers.results[1].pricing_tier_id

        warrant_token = Warrant::PricingTier.delete(tier1.pricing_tier_id)
        assert warrant_token
        warrant_token = Warrant::PricingTier.delete(tier2.pricing_tier_id)
        assert warrant_token
        pricing_tiers = Warrant::PricingTier.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, pricing_tiers.results.length
    end

    def test_crud_features
        feature1 = Warrant::Feature.create({ feature_id: "new-feature", meta: { name: "New Feature" } })
        assert_equal "new-feature", feature1.feature_id
        assert_equal({ name: "New Feature" }, feature1.meta)

        feature2 = Warrant::Feature.create({ feature_id: "feature-2" })
        fetched_feature = Warrant::Feature.get(feature2.feature_id, { warrant_token: "latest" })
        assert_equal feature2.feature_id, fetched_feature.feature_id
        assert_equal feature2.meta, fetched_feature.meta

        feature2 = feature2.update({ name: "Feature 2", description: "Second feature" })
        refetched_feature = Warrant::Feature.get(feature2.feature_id, { warrant_token: "latest" })
        assert_equal "feature-2", refetched_feature.feature_id
        assert_equal({ name: "Feature 2", description: "Second feature" }, refetched_feature.meta)

        features = Warrant::Feature.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 2, features.results.length
        assert_equal "feature-2", features.results[0].feature_id
        assert_equal "new-feature", features.results[1].feature_id

        warrant_token = Warrant::Feature.delete(feature1.feature_id)
        assert warrant_token
        warrant_token = Warrant::Feature.delete(feature2.feature_id)
        assert warrant_token
        features = Warrant::Feature.list({ limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, features.results.length
    end

    def test_crud_objects
        object1 = Warrant::Object.create(object_type: "document")
        assert_equal "document", object1.object_type
        assert object1.object_id
        assert_nil object1.meta

        object2 = Warrant::Object.create(object_type: "folder", object_id: "planning")
        refetched_object = Warrant::Object.get(object2.object_type, object2.object_id, { warrant_token: "latest" })
        assert_equal object2.object_type, refetched_object.object_type
        assert_equal object2.object_id, refetched_object.object_id
        assert_equal object2.meta, refetched_object.meta

        object2 = Warrant::Object.update(object2.object_type, object2.object_id, { description: "Second document" })
        refetched_object = Warrant::Object.get(object2.object_type, object2.object_id, { warrant_token: "latest" })
        assert_equal object2.object_type, refetched_object.object_type
        assert_equal object2.object_id, refetched_object.object_id
        assert_equal object2.meta, refetched_object.meta

        objects_list = Warrant::Object.list({ sort_by: "createdAt", limit: 10 }, { warrant_token: "latest" })
        assert_equal 2, objects_list.results.length
        assert_equal object1.object_type, objects_list.results[0].object_type
        assert_equal object1.object_id, objects_list.results[0].object_id
        assert_equal object2.object_type, objects_list.results[1].object_type
        assert_equal object2.object_id, objects_list.results[1].object_id

        objects_list = Warrant::Object.list({ sort_by: "createdAt", limit: 10, q: "planning" }, { warrant_token: "latest" })
        assert_equal 1, objects_list.results.length
        assert_equal object2.object_type, objects_list.results[0].object_type
        assert_equal object2.object_id, objects_list.results[0].object_id

        warrant_token = Warrant::Object.delete(object1.object_type, object1.object_id)
        assert warrant_token
        warrant_token = Warrant::Object.delete(object2.object_type, object2.object_id)
        assert warrant_token
        objects_list = Warrant::Object.list({ sort_by: "createdAt", limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, objects_list.results.length
    end

    def test_batch_create_delete_objects
        objects = Warrant::Object.batch_create([
            { object_type: "document", object_id: "document-a" },
            { object_type: "document", object_id: "document-b" },
            { object_type: "folder", object_id: "resources", meta: { description: "Helpful documents" }},
        ])
        assert_equal 3, objects.length

        fetched_objects = Warrant::Object.list({ sort_by: "createdAt", limit: 10 }, { warrant_token: "latest" })
        assert_equal 3, fetched_objects.results.length
        assert_equal "document", fetched_objects.results[0].object_type
        assert_equal "document-a", fetched_objects.results[0].object_id
        assert_equal "document", fetched_objects.results[1].object_type
        assert_equal "document-b", fetched_objects.results[1].object_id
        assert_equal "folder", fetched_objects.results[2].object_type
        assert_equal "resources", fetched_objects.results[2].object_id
        assert_equal({description: "Helpful documents"}, fetched_objects.results[2].meta)

        folder_resource = Warrant::Object.get("folder", "resources", { warrant_token: "latest" })
        assert_equal "folder", folder_resource.object_type
        assert_equal "resources", folder_resource.object_id

        warrant_token = Warrant::Object.batch_delete([
            { object_type: "document", object_id: "document-a" },
            { object_type: "document", object_id: "document-b" },
            { object_type: "folder", object_id: "resources", meta: { description: "Helpful documents" }},
        ])
        assert warrant_token
        fetched_objects = Warrant::Object.list({ sort_by: "createdAt", limit: 10 }, { warrant_token: "latest" })
        assert_equal 0, fetched_objects.results.length
    end

    def test_multitenancy
        # Create users
        user1 = Warrant::User.create
        user2 = Warrant::User.create

        # Create tenants
        tenant1 = Warrant::Tenant.create({ tenant_id: "tenant-1", meta: { name: "Tenant 1" } })
        tenant2 = Warrant::Tenant.create({ tenant_id: "tenant-2", meta: { name: "Tenant 2" } })

        user1_tenants = user1.list_tenants({ limit: 100 }, { warrant_token: "latest" })
        assert_equal 0, user1_tenants.results.length
        tenant1_users = tenant1.list_users({ limit: 100 }, { warrant_token: "latest" })
        assert_equal 0, tenant1_users.results.length

        # Assign user1 -> tenant1
        tenant1.assign_user(user1.user_id, relation: "member")

        user1_tenants = user1.list_tenants({ limit: 100 }, { warrant_token: "latest" })
        assert_equal 1, user1_tenants.results.length
        assert_equal "tenant-1", user1_tenants.results[0].tenant_id
        assert_equal({ name: "Tenant 1" }, user1_tenants.results[0].meta)

        tenant1_users = tenant1.list_users({ limit: 100 }, { warrant_token: "latest" })
        assert_equal 1, tenant1_users.results.length
        assert_equal user1.user_id, tenant1_users.results[0].user_id
        assert_nil tenant1_users.results[0].meta

        # Remove user1 -> tenant1
        tenant1.remove_user(user1.user_id, relation: "member")

        user1_tenants = user1.list_tenants({ limit: 100 }, { warrant_token: "latest" })
        assert_equal 0, user1_tenants.results.length

        tenant1_users = tenant1.list_users({ limit: 100 }, { warrant_token: "latest" })
        assert_equal 0, tenant1_users.results.length

        # Clean up
        warrant_token = Warrant::User.delete(user1.user_id)
        assert warrant_token
        warrant_token = Warrant::User.delete(user2.user_id)
        assert warrant_token
        warrant_token = Warrant::Tenant.delete(tenant1.tenant_id)
        assert warrant_token
        warrant_token = Warrant::Tenant.delete(tenant2.tenant_id)
        assert warrant_token
    end

    def test_rbac
        # Create users
        admin_user = Warrant::User.create
        viewer_user = Warrant::User.create

        # Create roles
        admin_role = Warrant::Role.create({ role_id: "admin", meta: { name: "Admin", description: "The admin role" } })
        viewer_role = Warrant::Role.create({ role_id: "viewer", meta: { name: "Viewer", description: "The viewer role" } })

        # Create permissions
        create_permission = Warrant::Permission.create({ permission_id: "create-report", meta: { name: "Create Report", description: "Permission to create reports" } })
        view_permission = Warrant::Permission.create({ permission_id: "view-report", meta: { name: "View Report", description: "Permission to view reports" } })

        assert_equal 0, admin_user.list_roles({ limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal 0, admin_role.list_permissions({ limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal false, admin_user.has_permission?(create_permission.permission_id, options: { warrant_token: "latest" })

        # Assign create-report permission to admin role and admin user
        admin_role.assign_permission(create_permission.permission_id)
        admin_user.assign_role(admin_role.role_id)

        assert_equal true, admin_user.has_permission?(create_permission.permission_id, options: { warrant_token: "latest" })

        admin_user_roles = admin_user.list_roles({ limit: 100 }, { warrant_token: "latest" })
        assert_equal 1, admin_user_roles.results.length
        assert_equal "admin", admin_user_roles.results[0].role_id
        assert_equal({ name: "Admin", description: "The admin role" }, admin_user_roles.results[0].meta)

        admin_role_permissions = admin_role.list_permissions({ limit: 100 }, { warrant_token: "latest" })
        assert_equal 1, admin_role_permissions.results.length
        assert_equal "create-report", admin_role_permissions.results[0].permission_id
        assert_equal({ name: "Create Report", description: "Permission to create reports" }, admin_role_permissions.results[0].meta)

        Warrant::Permission.remove_from_role("admin", "create-report")
        Warrant::Role.remove_from_user(admin_user.user_id, admin_role.role_id)

        assert_equal false, admin_user.has_permission?(create_permission.permission_id, options: { warrant_token: "latest" })
        assert_equal 0, admin_role.list_permissions({ limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal 0, admin_user.list_roles({ limit: 100 }, { warrant_token: "latest" }).results.length

        # Assign view-report to viewer user
        assert_equal 0, viewer_user.list_permissions({ limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal false, viewer_user.has_permission?("view-report", options: { warrant_token: "latest" })

        Warrant::Permission.assign_to_user(viewer_user.user_id, view_permission.permission_id)

        assert_equal true, Warrant::Warrant.user_has_permission?({ user_id: viewer_user.user_id, permission_id: view_permission.permission_id, relation: "member" })

        viewer_user_permissions = Warrant::Permission.list_for_user(viewer_user.user_id, { limit: 100 }, { warrant_token: "latest" })
        assert_equal 1, viewer_user_permissions.results.length
        assert_equal "view-report", viewer_user_permissions.results[0].permission_id

        viewer_user.remove_permission(view_permission.permission_id)

        assert_equal 0, viewer_user.list_permissions({ limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal false, viewer_user.has_permission?("view-report", options: { warrant_token: "latest" })

        # Clean up
        warrant_token = Warrant::User.delete(admin_user.user_id)
        assert warrant_token
        warrant_token = Warrant::User.delete(viewer_user.user_id)
        assert warrant_token
        warrant_token = Warrant::Role.delete(admin_role.role_id)
        assert warrant_token
        warrant_token = Warrant::Role.delete(viewer_role.role_id)
        assert warrant_token
        warrant_token = Warrant::Permission.delete(create_permission.permission_id)
        assert warrant_token
        warrant_token = Warrant::Permission.delete(view_permission.permission_id)
        assert warrant_token
    end

    def test_pricing_tiers_and_features_users
        # Create users
        free_user = Warrant::User.create
        paid_user = Warrant::User.create

        # Create pricing tiers
        free_tier = Warrant::PricingTier.create({ pricing_tier_id: "free", meta: { name: "Free Tier" } })
        paid_tier = Warrant::PricingTier.create({ pricing_tier_id: "paid" })

        # Create features
        custom_feature = Warrant::Feature.create({ feature_id: "custom-feature", meta: { name: "Custom Feature" } })
        feature1 = Warrant::Feature.create({ feature_id: "feature-1" })
        feature2 = Warrant::Feature.create({ feature_id: "feature-2" })

        # Assign custom-feature -> paid user
        assert_equal false, paid_user.has_feature?("custom-feature", options: { warrant_token: "latest" })
        assert_equal 0, paid_user.list_features({ limit: 100 }, { warrant_token: "latest" }).results.length

        paid_user.assign_feature(custom_feature.feature_id)

        assert_equal true, paid_user.has_feature?("custom-feature", options: { warrant_token: "latest" })

        paid_user_features = Warrant::Feature.list_for_user(paid_user.user_id, { limit: 100 }, { warrant_token: "latest" })

        assert_equal 1, paid_user_features.results.length
        assert_equal "custom-feature", paid_user_features.results[0].feature_id
        assert_equal({ name: "Custom Feature" }, paid_user_features.results[0].meta)

        Warrant::Feature.remove_from_user(paid_user.user_id, custom_feature.feature_id)

        assert_equal false, paid_user.has_feature?("custom-feature", options: { warrant_token: "latest" })
        assert_equal 0, paid_user.list_features({ limit: 100 }, { warrant_token: "latest" }).results.length

        # Assign feature-1 to free tier to free user
        assert_equal false, free_user.has_feature?("feature-1", options: { warrant_token: "latest" })
        assert_equal 0, Warrant::Feature.list_for_pricing_tier(free_tier.pricing_tier_id, { limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal 0, Warrant::PricingTier.list_for_user(free_user.user_id, { limit: 100 }, { warrant_token: "latest" }).results.length

        Warrant::Feature.assign_to_pricing_tier(free_tier.pricing_tier_id, feature1.feature_id)
        Warrant::PricingTier.assign_to_user(free_user.user_id, free_tier.pricing_tier_id)

        assert_equal true, free_tier.has_feature?("feature-1", options: { warrant_token: "latest" })
        assert_equal true, free_user.has_feature?("feature-1", options: { warrant_token: "latest" })

        free_tier_features = free_tier.list_features({ limit: 100 }, { warrant_token: "latest" })

        assert_equal 1, free_tier_features.results.length
        assert_equal "feature-1", free_tier_features.results[0].feature_id

        free_user_tiers = free_user.list_pricing_tiers({ limit: 100 }, { warrant_token: "latest" })

        assert_equal 1, free_user_tiers.results.length
        assert_equal "free", free_user_tiers.results[0].pricing_tier_id

        free_tier.remove_feature(feature1.feature_id)

        assert_equal false, free_user.has_feature?("feature-1", options: { warrant_token: "latest" })
        assert_equal 0, free_tier.list_features({ limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal 1, free_user.list_pricing_tiers({ limit: 100 }, { warrant_token: "latest" }).results.length

        free_user.remove_pricing_tier(free_tier.pricing_tier_id)

        assert_equal 0, free_user.list_pricing_tiers({ limit: 100 }, { warrant_token: "latest" }).results.length

        # Clean up
        warrant_token = Warrant::User.delete(free_user.user_id)
        assert warrant_token
        warrant_token = Warrant::User.delete(paid_user.user_id)
        assert warrant_token
        warrant_token = Warrant::PricingTier.delete(free_tier.pricing_tier_id)
        assert warrant_token
        warrant_token = Warrant::PricingTier.delete(paid_tier.pricing_tier_id)
        assert warrant_token
        warrant_token = Warrant::Feature.delete(custom_feature.feature_id)
        assert warrant_token
        warrant_token = Warrant::Feature.delete(feature1.feature_id)
        assert warrant_token
        warrant_token = Warrant::Feature.delete(feature2.feature_id)
        assert warrant_token
    end

    def test_pricing_tiers_and_features_tenants
        # Create tenants
        free_tenant = Warrant::Tenant.create
        paid_tenant = Warrant::Tenant.create

        # Create pricing tiers
        free_tier = Warrant::PricingTier.create({ pricing_tier_id: "free", meta: { name: "Free Tier" } })
        paid_tier = Warrant::PricingTier.create({ pricing_tier_id: "paid" })

        # Create features
        custom_feature = Warrant::Feature.create({ feature_id: "custom-feature", meta: { name: "Custom Feature" } })
        feature1 = Warrant::Feature.create({ feature_id: "feature-1", meta: { description: "First feature" } })
        feature2 = Warrant::Feature.create({ feature_id: "feature-2" })

        # Assign custom-feature to paid tenant
        assert_equal false, paid_tenant.has_feature?("custom-feature", options: { warrant_token: "latest" })
        assert_equal 0, paid_tenant.list_features({ limit: 100 }, { warrant_token: "latest" }).results.length

        paid_tenant.assign_feature(custom_feature.feature_id)

        assert_equal true, paid_tenant.has_feature?(custom_feature.feature_id, options: { warrant_token: "latest" })

        paid_tenant_features = Warrant::Feature.list_for_tenant(paid_tenant.tenant_id, { limit: 100 }, { warrant_token: "latest" })

        assert_equal 1, paid_tenant_features.results.length
        assert_equal "custom-feature", paid_tenant_features.results[0].feature_id

        Warrant::Feature.remove_from_tenant(paid_tenant.tenant_id, custom_feature.feature_id)

        assert_equal false, Warrant::Warrant.has_feature?(subject: { object_type: Warrant::Tenant::OBJECT_TYPE, object_id: paid_tenant.tenant_id }, relation: "member", feature_id: "custom-feature")
        assert_equal 0, paid_tenant.list_features.results.length

        # Assign feature-1 to free tier to free tenant
        assert_equal false, free_tenant.has_feature?("feature-1", options: { warrant_token: "latest" })
        assert_equal 0, free_tier.list_features({ limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal 0, free_tenant.list_pricing_tiers({ limit: 100 }, { warrant_token: "latest" }).results.length

        free_tier.assign_feature(feature1.feature_id)
        free_tenant.assign_pricing_tier(free_tier.pricing_tier_id)

        assert_equal true, free_tenant.has_feature?("feature-1", options: { warrant_token: "latest" })

        free_tier_features = Warrant::Feature.list_for_pricing_tier(free_tier.pricing_tier_id, { limit: 100 }, { warrant_token: "latest" })

        assert_equal 1, free_tier_features.results.length
        assert_equal "feature-1", free_tier_features.results[0].feature_id

        free_tenant_tiers = Warrant::PricingTier.list_for_tenant(free_tenant.tenant_id, { limit: 100 }, { warrant_token: "latest" })

        assert_equal 1, free_tenant_tiers.results.length
        assert_equal "free", free_tenant_tiers.results[0].pricing_tier_id

        free_tier.remove_feature(feature1.feature_id)

        assert_equal false, free_tenant.has_feature?("feature-1", options: { warrant_token: "latest" })
        assert_equal 0, free_tier.list_features({ limit: 100 }, { warrant_token: "latest" }).results.length
        assert_equal 1, free_tenant.list_pricing_tiers({ limit: 100 }, { warrant_token: "latest" }).results.length

        free_tenant.remove_pricing_tier(free_tier.pricing_tier_id)

        assert_equal 0, free_tenant.list_pricing_tiers({ limit: 100 }, { warrant_token: "latest" }).results.length

        # Clean up
        warrant_token = Warrant::Tenant.delete(free_tenant.tenant_id)
        assert warrant_token
        warrant_token = Warrant::Tenant.delete(paid_tenant.tenant_id)
        assert warrant_token
        warrant_token = Warrant::PricingTier.delete(free_tier.pricing_tier_id)
        assert warrant_token
        warrant_token = Warrant::PricingTier.delete(paid_tier.pricing_tier_id)
        assert warrant_token
        warrant_token = Warrant::Feature.delete(custom_feature.feature_id)
        assert warrant_token
        warrant_token = Warrant::Feature.delete(feature1.feature_id)
        assert warrant_token
        warrant_token = Warrant::Feature.delete(feature2.feature_id)
        assert warrant_token
    end

    def test_sessions
        user = Warrant::User.create
        tenant = Warrant::Tenant.create

        Warrant::Warrant.create({ object_type: Warrant::Tenant::OBJECT_TYPE, object_id: tenant.tenant_id }, "admin", { object_type: Warrant::User::OBJECT_TYPE, object_id: user.user_id })
        Warrant::Permission.assign_to_user(user.user_id, "view-self-service-dashboard")

        assert Warrant::Session.create_authorization_session(user_id: user.user_id)
        assert Warrant::Session.create_self_service_session("http://localhost:8080", user_id: user.user_id, tenant_id: tenant.tenant_id, self_service_strategy: "rbac")

        warrant_token = Warrant::User.delete(user.user_id)
        assert warrant_token
        warrant_token = Warrant::Tenant.delete(tenant.tenant_id)
        assert warrant_token
    end

    def test_warrants
        user1 = Warrant::User.create({ user_id: "user-1" })
        user2 = Warrant::User.create({ user_id: "user-2" })
        new_permission = Warrant::Permission.create(permission_id: "perm1", name: "Permission 1", description: "Permission 1")

        assert_equal false, Warrant::Warrant.check(new_permission, "member", user1, { warrant_token: "latest" })

        warrant1 = Warrant::Warrant.create(new_permission, "member", user1)
        assert warrant1.warrant_token
        warrant2 = Warrant::Warrant.create(new_permission, "member", user2)
        assert warrant2.warrant_token

        warrants1 = Warrant::Warrant.list({ limit: 1 }, { warrant_token: "latest" })
        assert_equal 1, warrants1.results.length
        assert_equal "permission", warrants1.results[0].object_type
        assert_equal "perm1", warrants1.results[0].object_id
        assert_equal "member", warrants1.results[0].relation
        assert_equal "user", warrants1.results[0].subject.object_type
        assert_equal "user-1", warrants1.results[0].subject.object_id

        warrants2 = Warrant::Warrant.list({ limit: 1, next_cursor: warrants1.next_cursor }, { warrant_token: "latest" })
        assert_equal 1, warrants2.results.length
        assert_equal "permission", warrants2.results[0].object_type
        assert_equal "perm1", warrants2.results[0].object_id
        assert_equal "member", warrants2.results[0].relation
        assert_equal "user", warrants2.results[0].subject.object_type
        assert_equal "user-2", warrants2.results[0].subject.object_id

        warrants3 = Warrant::Warrant.list({ subject_id: user1.user_id }, { warrant_token: "latest" })
        assert_equal 1, warrants3.results.length
        assert_equal "permission", warrants3.results[0].object_type
        assert_equal "perm1", warrants3.results[0].object_id
        assert_equal "member", warrants3.results[0].relation
        assert_equal "user", warrants3.results[0].subject.object_type
        assert_equal "user-1", warrants3.results[0].subject.object_id

        assert_equal true, Warrant::Warrant.check(new_permission, "member", user1, { warrant_token: "latest" })
        assert_equal true, Warrant::Warrant.check_many(
            "allOf",
            [
                { object: new_permission, relation: "member", subject: user1 },
                { object: { object_type: "permission", object_id: "perm1" }, relation: "member", subject: { object_type: "user", object_id: "user-1" }}
            ],
            { warrant_token: "latest" }
        )

        query_response = Warrant::Warrant.query("select permission where user:#{user1.user_id} is member")
        assert_equal 1, query_response.results.length
        assert_equal "permission", query_response.results[0].object_type
        assert_equal "perm1", query_response.results[0].object_id
        assert_equal "member", query_response.results[0].warrant.relation

        warrant_token = Warrant::Warrant.delete(new_permission, "member", user1)
        assert warrant_token
        warrant_token = Warrant::Warrant.delete(new_permission, "member", user2)
        assert warrant_token

        assert_equal false, Warrant::Warrant.check(new_permission, "member", user1, { warrant_token: "latest" })

        warrant_token = Warrant::User.delete(user1.user_id)
        assert warrant_token
        warrant_token = Warrant::User.delete(user2.user_id)
        assert warrant_token
        warrant_token = Warrant::Permission.delete(new_permission.permission_id)
        assert warrant_token
    end

    def test_batch_create_delete_warrants
        new_user = Warrant::User.create
        permission1 = Warrant::Permission.create({ permission_id: "perm1", meta: { name: "Permission 1", description: "Permission 1" } })
        permission2 = Warrant::Permission.create({ permission_id: "perm2", meta: { name: "Permission 2", description: "Permission 2" } })

        user_has_permission1 = Warrant::Warrant.check(permission1, "member", new_user, { warrant_token: "latest" })
        assert_equal false, user_has_permission1

        user_has_permission2 = Warrant::Warrant.check(permission2, "member", new_user, { warrant_token: "latest" })
        assert_equal false, user_has_permission2

        warrants = Warrant::Warrant.batch_create([
            {
                object: permission1,
                relation: "member",
                subject: new_user
            },
            {
                object: permission2,
                relation: "member",
                subject: new_user
            }
        ])
        assert_equal 2, warrants.length
        warrants.each{ |warrant|
            assert warrant.warrant_token
        }

        user_has_permission1 = Warrant::Warrant.check(permission1, "member", new_user, { warrant_token: "latest" })
        assert_equal true, user_has_permission1

        user_has_permission2 = Warrant::Warrant.check(permission2, "member", new_user, { warrant_token: "latest" })
        assert_equal true, user_has_permission2

        warrant_token = Warrant::Warrant.batch_delete([
            {
                object: permission1,
                relation: "member",
                subject: new_user
            },
            {
                object: permission2,
                relation: "member",
                subject: new_user
            }
        ])
        assert warrant_token
        warrant_token = Warrant::Object.batch_delete([
            { object_type: "permission", object_id: permission1.permission_id },
            { object_type: "permission", object_id: permission2.permission_id },
            { object_type: "user", object_id: new_user.user_id },
        ])
        assert warrant_token
    end

    def test_warrants_with_policy
        new_user = Warrant::User.create({ user_id: "user-1" })
        new_permission = Warrant::Permission.create({ permission_id: "test-permission" })

        warrant = Warrant::Warrant.create(new_permission, "member", new_user, "geo == 'us'")
        assert warrant.warrant_token

        assert_equal true, Warrant::Warrant.check(new_permission, "member", new_user, context: { "geo": "us" })
        assert_equal false, Warrant::Warrant.check(new_permission, "member", new_user, context: { "geo": "eu" })

        warrant_token = Warrant::Warrant.delete(new_permission, "member", new_user, "geo == 'us'")
        assert warrant_token

        assert_equal false, Warrant::Warrant.check(new_permission, "member", new_user, { "geo": "us" })

        warrant_token = Warrant::User.delete(new_user.user_id)
        assert warrant_token
        warrant_token = Warrant::Permission.delete(new_permission.permission_id)
        assert warrant_token
    end

    def test_query
        user_a = Warrant::User.create({ user_id: "userA" })
        user_b = Warrant::User.create({ user_id: "userB" })
        permission1 = Warrant::Permission.create({ permission_id: "perm1", meta: { name: "Permission 1", description: "This is permission 1." } })
        permission2 = Warrant::Permission.create({ permission_id: "perm2" })
        permission3 = Warrant::Permission.create({ permission_id: "perm3", meta: { name: "Permission 3", description: "This is permission 3." } })
        role1 = Warrant::Role.create({ role_id: "role1", meta: { name: "Role 1", description: "This is role 1." } })
        role2 = Warrant::Role.create({ role_id: "role2", meta: { name: "Role 2" } })

        created_warrant = role1.assign_permission(permission1.permission_id)
        assert created_warrant.warrant_token
        created_warrant = role2.assign_permission(permission2.permission_id)
        assert created_warrant.warrant_token
        created_warrant = role2.assign_permission(permission3.permission_id)
        assert created_warrant.warrant_token
        created_warrant = Warrant::Warrant.create(role2, "member", role1)
        assert created_warrant.warrant_token
        created_warrant = user_a.assign_role(role1.role_id)
        assert created_warrant.warrant_token
        created_warrant = user_b.assign_role(role2.role_id)
        assert created_warrant.warrant_token

        result_set = Warrant::Warrant.query("select role where user:userA is member", filters: { limit: 1 })
        assert_equal 1, result_set.results.length
        assert_equal "role", result_set.results[0].object_type
        assert_equal "role1", result_set.results[0].object_id
        assert_equal false, result_set.results[0].is_implicit
        assert_equal "role", result_set.results[0].warrant.object_type
        assert_equal "role1", result_set.results[0].warrant.object_id
        assert_equal "member", result_set.results[0].warrant.relation
        assert_equal "user", result_set.results[0].warrant.subject.object_type
        assert_equal "userA", result_set.results[0].warrant.subject.object_id

        result_set = Warrant::Warrant.query("select role where user:userA is member", filters: { limit: 1, next_cursor: result_set.next_cursor })
        assert_equal 1, result_set.results.length
        assert_equal "role", result_set.results[0].object_type
        assert_equal "role2", result_set.results[0].object_id
        assert_equal true, result_set.results[0].is_implicit
        assert_equal "role", result_set.results[0].warrant.object_type
        assert_equal "role2", result_set.results[0].warrant.object_id
        assert_equal "member", result_set.results[0].warrant.relation
        assert_equal "role", result_set.results[0].warrant.subject.object_type
        assert_equal "role1", result_set.results[0].warrant.subject.object_id

        warrant_token = Warrant::User.delete(user_a.user_id)
        assert warrant_token
        warrant_token = Warrant::User.delete(user_b.user_id)
        assert warrant_token
        warrant_token = Warrant::Permission.delete(permission1.permission_id)
        assert warrant_token
        warrant_token = Warrant::Permission.delete(permission2.permission_id)
        assert warrant_token
        warrant_token = Warrant::Permission.delete(permission3.permission_id)
        assert warrant_token
        warrant_token = Warrant::Role.delete(role1.role_id)
        assert warrant_token
        warrant_token = Warrant::Role.delete(role2.role_id)
        assert warrant_token
    end
end
