# frozen_string_literal: true

require "test_helper"

class RoleTest < Minitest::Test
    def test_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/roles")
            .with(body: "{\"roleId\":\"admin\",\"name\":\"Admin\"}")
            .to_return(body: '{"roleId": "admin", "name": "Admin", "description": null}')

        created_role = Warrant::Role.create(role_id: "admin", name: "Admin")

        assert_equal "admin", created_role.role_id
        assert_equal "Admin", created_role.name
        assert_nil created_role.description
    end

    def test_delete
        stub_request(:delete, "#{Warrant.config.api_base}/v1/roles/some-role")

        assert_nil Warrant::Role.delete("some-role")
    end

    def test_list
        stub_request(:get, "#{Warrant.config.api_base}/v1/roles")
            .to_return(body: '[{"roleId": "role-1", "name": null, "description": null}, {"roleId": "role-2", "name": "Second Role", "description": null}]')

        roles = Warrant::Role.list

        assert_equal 2, roles.length

        assert_equal "role-1", roles[0].role_id
        assert_nil roles[0].name
        assert_nil roles[0].description

        assert_equal "role-2", roles[1].role_id
        assert_equal "Second Role", roles[1].name
        assert_nil roles[1].description
    end

    def test_get
        stub_request(:get, "#{Warrant.config.api_base}/v1/roles/some-role")
            .to_return(body: '{"roleId": "some-role", "name": "My Tenant", "description": "Role for new users"}')

        role = Warrant::Role.get("some-role")

        assert_equal "some-role", role.role_id
        assert_equal "My Tenant", role.name
        assert_equal "Role for new users", role.description
    end

    def test_update
        stub_request(:put, "#{Warrant.config.api_base}/v1/roles/some-role")
            .with(body: "{\"name\":\"Some Role\"}")
            .to_return(body: '{"roleId": "some-role", "name": "Some Role", "description": null}')

        role = Warrant::Role.update("some-role", { name: "Some Role" })

        assert_equal "some-role", role.role_id
        assert_equal "Some Role", role.name
        assert_nil role.description
    end

    def test_list_for_user
        stub_request(:get, "#{Warrant.config.api_base}/v1/users/user-1/roles")
            .to_return(body: '[{"roleId": "role-1", "name": null, "description": "first role"}, {"roleId": "role-2", "name": "Second Role", "description": null}]')

        roles = Warrant::Role.list_for_user("user-1")

        assert_equal 2, roles.length

        assert_equal "role-1", roles[0].role_id
        assert_nil roles[0].name
        assert_equal "first role", roles[0].description

        assert_equal "role-2", roles[1].role_id
        assert_equal "Second Role", roles[1].name
        assert_nil roles[1].description
    end

    def test_assign_to_user
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "role", "objectId": "admin", "relation": "member", "subject": {"objectType": "user", "objectId": "user-1"}}')

        assigned_role = Warrant::Role.assign_to_user("user-1", "admin")

        assert_equal "role", assigned_role.object_type
        assert_equal "admin", assigned_role.object_id
        assert_equal "member", assigned_role.relation
        assert_equal "user", assigned_role.subject.object_type
        assert_equal "user-1", assigned_role.subject.object_id
    end

    def test_remove_from_user
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::Role.remove_from_user("user-1", "admin")
    end
end
