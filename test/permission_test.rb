# frozen_string_literal: true

require "test_helper"

class PermissionTest < Minitest::Test
    def test_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/permissions")
            .with(body: "{\"permissionId\":\"edit-store\",\"name\":\"Edit Store\"}")
            .to_return(body: '{"permissionId": "edit-store", "name": "Edit Store", "description": null}')

        created_permission = Warrant::Permission.create(permission_id: "edit-store", name: "Edit Store")

        assert_equal "edit-store", created_permission.permission_id
        assert_equal "Edit Store", created_permission.name
        assert_nil created_permission.description
    end

    def test_delete
        stub_request(:delete, "#{Warrant.config.api_base}/v1/permissions/some-permission")

        assert_nil Warrant::Permission.delete("some-permission")
    end

    def test_list
        stub_request(:get, "#{Warrant.config.api_base}/v1/permissions")
            .to_return(body: '[{"permissionId": "permission-1", "name": null, "description": null}, {"permissionId": "permission-2", "name": "Second Permission", "description": null}]')

        permissions = Warrant::Permission.list

        assert_equal 2, permissions.length

        assert_equal "permission-1", permissions[0].permission_id
        assert_nil permissions[0].name
        assert_nil permissions[0].description

        assert_equal "permission-2", permissions[1].permission_id
        assert_equal "Second Permission", permissions[1].name
        assert_nil permissions[1].description
    end

    def test_get
        stub_request(:get, "#{Warrant.config.api_base}/v1/permissions/some-permission")
            .to_return(body: '{"permissionId": "some-permission", "name": "My Tenant", "description": "Permission for new users"}')

        permission = Warrant::Permission.get("some-permission")

        assert_equal "some-permission", permission.permission_id
        assert_equal "My Tenant", permission.name
        assert_equal "Permission for new users", permission.description
    end

    def test_update
        stub_request(:put, "#{Warrant.config.api_base}/v1/permissions/some-permission")
            .with(body: "{\"name\":\"Some Permission\"}")
            .to_return(body: '{"permissionId": "some-permission", "name": "Some Permission", "description": null}')

        permission = Warrant::Permission.update("some-permission", { name: "Some Permission" })

        assert_equal "some-permission", permission.permission_id
        assert_equal "Some Permission", permission.name
        assert_nil permission.description
    end

    def test_list_for_role
        stub_request(:get, "#{Warrant.config.api_base}/v1/roles/role-1/permissions")
            .to_return(body: '[{"permissionId": "permission-1", "name": null, "description": "first permission"}, {"permissionId": "permission-2", "name": "Second Permission", "description": null}]')

        permissions = Warrant::Permission.list_for_role("role-1")

        assert_equal 2, permissions.length

        assert_equal "permission-1", permissions[0].permission_id
        assert_nil permissions[0].name
        assert_equal "first permission", permissions[0].description

        assert_equal "permission-2", permissions[1].permission_id
        assert_equal "Second Permission", permissions[1].name
        assert_nil permissions[1].description
    end

    def test_assign_to_role
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "permission", "objectId": "edit-store", "relation": "member", "subject": {"objectType": "role", "objectId": "role-1"}}')

        assigned_permission = Warrant::Permission.assign_to_role("role-1", "edit-store")

        assert_equal "permission", assigned_permission.object_type
        assert_equal "edit-store", assigned_permission.object_id
        assert_equal "member", assigned_permission.relation
        assert_equal "role", assigned_permission.subject.object_type
        assert_equal "role-1", assigned_permission.subject.object_id
    end

    def test_remove_from_role
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::Permission.remove_from_role("role-1", "edit-store")
    end

    def test_list_for_user
        stub_request(:get, "#{Warrant.config.api_base}/v1/users/user-1/permissions")
            .to_return(body: '[{"permissionId": "permission-1", "name": null, "description": "first permission"}, {"permissionId": "permission-2", "name": "Second Permission", "description": null}]')

        permissions = Warrant::Permission.list_for_user("user-1")

        assert_equal 2, permissions.length

        assert_equal "permission-1", permissions[0].permission_id
        assert_nil permissions[0].name
        assert_equal "first permission", permissions[0].description

        assert_equal "permission-2", permissions[1].permission_id
        assert_equal "Second Permission", permissions[1].name
        assert_nil permissions[1].description
    end

    def test_assign_to_user
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "permission", "objectId": "edit-store", "relation": "member", "subject": {"objectType": "user", "objectId": "user-1"}}')

        assigned_permission = Warrant::Permission.assign_to_user("user-1", "edit-store")

        assert_equal "permission", assigned_permission.object_type
        assert_equal "edit-store", assigned_permission.object_id
        assert_equal "member", assigned_permission.relation
        assert_equal "user", assigned_permission.subject.object_type
        assert_equal "user-1", assigned_permission.subject.object_id
    end

    def test_remove_from_user
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::Permission.remove_from_user("user-1", "edit-store")
    end
end
