# frozen_string_literal: true

require "test_helper"

class TenantTest < Minitest::Test
    def setup
        Warrant.config.use_ssl = true
    end

    def test_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/tenants")
        .with(body: "{\"tenantId\":\"new-tenant\",\"name\":\"My Tenant\"}")
        .to_return(body: '{"tenantId": "new-tenant", "name": "My Tenant", "createdAt": "2022-12-16"}')

        created_tenant = Warrant::Tenant.create(tenant_id: "new-tenant", name: "My Tenant")

        assert_equal "new-tenant", created_tenant.tenant_id
        assert_equal "My Tenant", created_tenant.name
        assert_equal "2022-12-16", created_tenant.created_at
    end

    def test_batch_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/tenants")
        .with(body: "[{\"tenantId\":\"batch-tenant-1\"},{\"tenantId\":\"batch-tenant-2\"}]")
        .to_return(body: '[{"tenantId": "batch-tenant-1", "name": null, "createdAt": "2022-12-16"}, {"tenantId": "batch-tenant-2", "name": null, "createdAt": "2022-12-16"}]')

        created_tenants = Warrant::Tenant.batch_create([{ tenant_id: "batch-tenant-1" }, { tenant_id: "batch-tenant-2" }])

        assert_equal 2, created_tenants.length

        assert_equal "batch-tenant-1", created_tenants[0].tenant_id
        assert_nil created_tenants[0].name
        assert_equal "2022-12-16", created_tenants[0].created_at

        assert_equal "batch-tenant-2", created_tenants[1].tenant_id
        assert_nil created_tenants[1].name
        assert_equal "2022-12-16", created_tenants[1].created_at
    end

    def test_delete
        stub_request(:delete, "#{Warrant.config.api_base}/v1/tenants/some-tenant")

        assert_nil Warrant::Tenant.delete("some-tenant")
    end

    def test_list
        stub_request(:get, "#{Warrant.config.api_base}/v1/tenants")
        .to_return(body: '[{"tenantId": "tenant-1", "name": null, "createdAt": "2022-01-01"}, {"tenantId": "tenant-2", "name": "tenant2@test.com", "createdAt": "2022-06-12"}]')

        tenants = Warrant::Tenant.list

        assert_equal 2, tenants.length

        assert_equal "tenant-1", tenants[0].tenant_id
        assert_nil tenants[0].name
        assert_equal "2022-01-01", tenants[0].created_at

        assert_equal "tenant-2", tenants[1].tenant_id
        assert_equal "tenant2@test.com", tenants[1].name
        assert_equal "2022-06-12", tenants[1].created_at
    end

    def test_get
        stub_request(:get, "#{Warrant.config.api_base}/v1/tenants/some-tenant")
        .to_return(body: '{"tenantId": "some-tenant", "name": "My Tenant", "createdAt": "2022-12-16"}')

        tenant = Warrant::Tenant.get("some-tenant")

        assert_equal "some-tenant", tenant.tenant_id
        assert_equal "My Tenant", tenant.name
        assert_equal '2022-12-16', tenant.created_at
    end

    def test_update
        stub_request(:put, "#{Warrant.config.api_base}/v1/tenants/some-tenant")
        .with(body: "{\"name\":\"updated-name@test.com\"}")
        .to_return(body: '{"tenantId": "some-tenant", "name": "updated-name@test.com", "createdAt": "2022-12-16"}')

        tenant = Warrant::Tenant.update("some-tenant", { name: "updated-name@test.com" })

        assert_equal "some-tenant", tenant.tenant_id
        assert_equal "updated-name@test.com", tenant.name
        assert_equal '2022-12-16', tenant.created_at
    end

    def test_list_for_user
        stub_request(:get, "#{Warrant.config.api_base}/v1/users/user-1/tenants")
        .to_return(body: '[{"tenantId": "tenant-1", "name": null, "createdAt": "2022-01-01"}, {"tenantId": "tenant-2", "name": "Tenant Two", "createdAt": "2022-06-12"}]')

        tenants = Warrant::Tenant.list_for_user("user-1")

        assert_equal 2, tenants.length

        assert_equal "tenant-1", tenants[0].tenant_id
        assert_nil tenants[0].name
        assert_equal "2022-01-01", tenants[0].created_at

        assert_equal "tenant-2", tenants[1].tenant_id
        assert_equal "Tenant Two", tenants[1].name
        assert_equal "2022-06-12", tenants[1].created_at
    end
end
