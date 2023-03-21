# frozen_string_literal: true

require "test_helper"

class UserTest < Minitest::Test
    def setup
        Warrant.config.use_ssl = false
    end

    def test_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/users")
            .with(body: "{\"userId\":\"new-user\",\"email\":\"user@test.com\"}")
            .to_return(body: '{"userId": "new-user", "email": "user@test.com", "createdAt": "2022-12-16"}')

        created_user = Warrant::User.create(user_id: "new-user", email: "user@test.com")

        assert_equal "new-user", created_user.user_id
        assert_equal "user@test.com", created_user.email
        assert_equal "2022-12-16", created_user.created_at
    end

    def test_create__raises_error
        stub_request(:post, "#{Warrant.config.api_base}/v1/users")
            .with(body: "{\"userId\":\"new-user\",\"email\":\"user@test.com\"}")
            .to_raise(Warrant::DuplicateRecordError)

        assert_raises Warrant::DuplicateRecordError do
        Warrant::User.create(user_id: "new-user", email: "user@test.com")
        end
    end

    def test_batch_create
        stub_request(:post, "#{Warrant.config.api_base}/v1/users")
            .with(body: "[{\"userId\":\"batch-user-1\"},{\"userId\":\"batch-user-2\"}]")
            .to_return(body: '[{"userId": "batch-user-1", "email": null, "createdAt": "2022-12-16"}, {"userId": "batch-user-2", "email": null, "createdAt": "2022-12-16"}]')

        created_users = Warrant::User.batch_create([{ user_id: "batch-user-1" }, { user_id: "batch-user-2" }])

        assert_equal 2, created_users.length

        assert_equal "batch-user-1", created_users[0].user_id
        assert_nil created_users[0].email
        assert_equal "2022-12-16", created_users[0].created_at

        assert_equal "batch-user-2", created_users[1].user_id
        assert_nil created_users[1].email
        assert_equal "2022-12-16", created_users[1].created_at
    end

    def test_batch_create__raises_error
        stub_request(:post, "#{Warrant.config.api_base}/v1/users")
            .with(body: "[{\"userId\":\"batch-user-1\"},{\"userId\":\"batch-user-2\"}]")
            .to_raise(Warrant::DuplicateRecordError)

        assert_raises Warrant::DuplicateRecordError do
        Warrant::User.batch_create([{ user_id: "batch-user-1" }, { user_id: "batch-user-2" }])
        end
    end

    def test_delete
        stub_request(:delete, "#{Warrant.config.api_base}/v1/users/some-user")

        assert_nil Warrant::User.delete("some-user")
    end

    def test_delete__raises_error
        stub_request(:delete, "#{Warrant.config.api_base}/v1/users/some-user")
            .to_raise(Warrant::NotFoundError)

        assert_raises Warrant::NotFoundError do
        Warrant::User.delete("some-user")
        end
    end

    def test_list
        stub_request(:get, "#{Warrant.config.api_base}/v1/users")
            .to_return(body: '[{"userId": "user-1", "email": null, "createdAt": "2022-01-01"}, {"userId": "user-2", "email": "user2@test.com", "createdAt": "2022-06-12"}]')

        users = Warrant::User.list

        assert_equal 2, users.length

        assert_equal "user-1", users[0].user_id
        assert_nil users[0].email
        assert_equal "2022-01-01", users[0].created_at

        assert_equal "user-2", users[1].user_id
        assert_equal "user2@test.com", users[1].email
        assert_equal "2022-06-12", users[1].created_at
    end

    def test_list__raises_error
        stub_request(:get, "#{Warrant.config.api_base}/v1/users")
            .to_raise(Warrant::InternalError)

        assert_raises Warrant::InternalError do
        Warrant::User.list
        end
    end

    def test_get
        stub_request(:get, "#{Warrant.config.api_base}/v1/users/some-user")
            .to_return(body: '{"userId": "some-user", "email": "user@test.com", "createdAt": "2022-12-16"}')

        user = Warrant::User.get("some-user")

        assert_equal "some-user", user.user_id
        assert_equal "user@test.com", user.email
        assert_equal '2022-12-16', user.created_at
    end

    def test_get__raises_error
        stub_request(:get, "#{Warrant.config.api_base}/v1/users/some-user")
            .to_raise(Warrant::NotFoundError)

        assert_raises Warrant::NotFoundError do
        Warrant::User.get("some-user")
        end
    end

    def test_update
        stub_request(:put, "#{Warrant.config.api_base}/v1/users/some-user")
            .with(body: "{\"email\":\"updated-email@test.com\"}")
            .to_return(body: '{"userId": "some-user", "email": "updated-email@test.com", "createdAt": "2022-12-16"}')

        user = Warrant::User.update("some-user", { email: "updated-email@test.com" })

        assert_equal "some-user", user.user_id
        assert_equal "updated-email@test.com", user.email
        assert_equal '2022-12-16', user.created_at
    end

    def test_update__raises_error
        stub_request(:put, "#{Warrant.config.api_base}/v1/users/some-user")
            .with(body: "{\"email\":\"updated-email@test.com\"}")
            .to_raise(Warrant::NotFoundError)

        assert_raises Warrant::NotFoundError do
        Warrant::User.update("some-user", { email: "updated-email@test.com" })
        end
    end

    def test_list_for_tenant
        stub_request(:get, "#{Warrant.config.api_base}/v1/tenants/my-store/users")
            .to_return(body: '[{"userId": "user-1", "email": null, "createdAt": "2022-01-01"}, {"userId": "user-2", "email": "user2@test.com", "createdAt": "2022-06-12"}]')

        users = Warrant::User.list_for_tenant("my-store")

        assert_equal 2, users.length

        assert_equal "user-1", users[0].user_id
        assert_nil users[0].email
        assert_equal "2022-01-01", users[0].created_at

        assert_equal "user-2", users[1].user_id
        assert_equal "user2@test.com", users[1].email
        assert_equal "2022-06-12", users[1].created_at
    end

    def test_list_for_tenant__raises_error
        stub_request(:get, "#{Warrant.config.api_base}/v1/tenants/my-store/users")
            .to_raise(Warrant::UnauthorizedError)

        assert_raises Warrant::UnauthorizedError do
        Warrant::User.list_for_tenant("my-store")
        end
    end

    def test_assign_to_tenant
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_return(body: '{"objectType": "tenant", "objectId": "my-store", "relation": "member", "subject": { "objectType": "user", "objectId": "new-employee" }}')

        warrant = Warrant::User.assign_to_tenant("my-store", "new-employee")

        assert_equal "tenant", warrant.object_type
        assert_equal "my-store", warrant.object_id
        assert_equal "member", warrant.relation
        assert_equal "user", warrant.subject.object_type
        assert_equal "new-employee", warrant.subject.object_id
    end

    def test_assign_to_tenant__raises_error
        stub_request(:post, "#{Warrant.config.api_base}/v1/warrants")
            .to_raise(Warrant::InternalError)

        assert_raises Warrant::InternalError do
        Warrant::User.assign_to_tenant("my-store", "new-employee")
        end
    end

    def test_remove_from_tenant
        stub_request(:delete, "#{Warrant.config.api_base}/v1/warrants")

        assert_nil Warrant::User.remove_from_tenant("my-store", "new-employee")
    end
end
