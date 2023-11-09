# frozen_string_literal: true

require "test_helper"

class ObjectTest < Minitest::Test
    def setup
        Warrant.config.use_ssl = false
    end

    def test_create
        stub_request(:post, "#{Warrant.config.api_base}/v2/objects")
        .with(body: "{\"objectType\":\"user\",\"objectId\":\"new-user\",\"meta\":{\"name\":\"New User\"}}")
        .to_return(body: '{"objectType": "user", "objectId": "new-user", "meta": {"name": "New User"}, "createdAt": "2022-12-16"}')

        created_object = Warrant::Object.create(object_type: "user", object_id: "new-user", meta: { name: "New User" })

        assert_equal "user", created_object.object_type
        assert_equal "new-user", created_object.object_id
        assert_equal({"name" => "New User"}, created_object.meta)
        assert_equal "2022-12-16", created_object.created_at
    end

    def test_batch_create
        stub_request(:post, "#{Warrant.config.api_base}/v2/objects")
        .with(body: "[{\"objectType\":\"user\",\"objectId\":\"batch-user-1\"},{\"objectType\":\"user\",\"objectId\":\"batch-user-2\"}]")
        .to_return(body: '[{"objectType": "user", "objectId": "batch-user-1", "createdAt": "2022-12-16"}, {"objectType": "user", "objectId": "batch-user-2", "createdAt": "2022-12-16"}]')

        created_objects = Warrant::Object.batch_create([{ object_type: "user", object_id: "batch-user-1" }, { object_type: "user", object_id: "batch-user-2" }])

        assert_equal 2, created_objects.length

        assert_equal "user", created_objects[0].object_type
        assert_equal "batch-user-1", created_objects[0].object_id
        assert_nil created_objects[0].meta
        assert_equal "2022-12-16", created_objects[0].created_at

        assert_equal "user", created_objects[1].object_type
        assert_equal "batch-user-2", created_objects[1].object_id
        assert_nil created_objects[1].meta
        assert_equal "2022-12-16", created_objects[1].created_at
    end

    def test_delete
        stub_request(:delete, "#{Warrant.config.api_base}/v2/objects/tenant/some-tenant")

        assert_nil Warrant::Object.delete("tenant", "some-tenant")
    end

    def test_list
        stub_request(:get, "#{Warrant.config.api_base}/v2/objects")
        .to_return(body: '[{"objectType": "document", "objectId": "document-1", "meta": null, "createdAt": "2022-01-01"}, {"objectType": "folder", "objectId": "new-folder", "meta": {"description": "My folder"}, "createdAt": "2022-06-12"}]')

        objects = Warrant::Object.list

        assert_equal 2, objects.length

        assert_equal "document", objects[0].object_type
        assert_equal "document-1", objects[0].object_id
        assert_nil objects[0].meta
        assert_equal "2022-01-01", objects[0].created_at

        assert_equal "folder", objects[1].object_type
        assert_equal "new-folder", objects[1].object_id
        assert_equal({"description" => "My folder"}, objects[1].meta)
        assert_equal "2022-06-12", objects[1].created_at
    end

    def test_get
        stub_request(:get, "#{Warrant.config.api_base}/v2/objects/item/some-item")
        .to_return(body: '{"objectType": "item", "objectId": "some-item", "meta": null, "createdAt": "2022-12-16"}')

        object = Warrant::Object.get("item", "some-item")

        assert_equal "item", object.object_type
        assert_equal "some-item", object.object_id
        assert_nil object.meta
        assert_equal '2022-12-16', object.created_at
    end

    def test_update
        stub_request(:put, "#{Warrant.config.api_base}/v2/objects/item/some-item")
        .with(body: "{\"meta\":{\"name\":\"Updated Name\"}}")
        .to_return(body: '{"objectType": "item", "objectId": "some-item", "meta": {"name": "Updated Name"}, "createdAt": "2022-12-16"}')

        object = Warrant::Object.update("item", "some-item", { name: "Updated Name" })

        assert_equal "item", object.object_type
        assert_equal "some-item", object.object_id
        assert_equal({"name" => "Updated Name"}, object.meta)
        assert_equal '2022-12-16', object.created_at
    end
end
