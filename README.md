# Warrant Ruby Library

Use [Warrant](https://warrant.dev/) in ruby projects.

[![Gem Version](https://badge.fury.io/rb/warrant.svg)](https://badge.fury.io/rb/warrant)
[![Discord](https://img.shields.io/discord/865661082203193365?label=discord)](https://discord.gg/QNCMKWzqET)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'warrant'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install warrant

## Usage

```ruby
require 'warrant'
Warrant.api_key = 'api_test_f5dsKVeYnVSLHGje44zAygqgqXiLJBICbFzCiAg1E='
```

### `create_user(user_id, username)`

This method creates a user entity in Warrant with the specified `userId`. Provide an optional `username` to make it easier to identify users in the Warrant dashboard.

```ruby
# Create user with `user.id` as the user_id and `user.email` as the username
Warrant::WarrantClient.create_user(user.id, user.email)

# Create user with generated id
Warrant::WarrantClient.create_user()
```

### `create_warrant(objectType, objectId, relation, user)`

This method creates a warrant which specifies that the provided `user` (or userset) has `relation` on the object of type `objectType` with id `objectId`.

```ruby
# Create a warrant allowing user.id to "view" the store with id store.id
Warrant::WarrantClient.create_warrant('store', store.id, 'view', { userId: user.id })
```

### `create_session(userId)`

This method creates a session in Warrant for the user with the specified `userId` and returns a session token which can be used to make authorized requests to the Warrant API only for the specified user. This session token can safely be used to make requests to the Warrant API's authorization endpoint to determine user access in web and mobile client applications.

```ruby
# Create session token for user
Warrant::WarrantClient.create_session(user.id)
```

### `is_authorized(objectType, objectId, relation, userId)`

This method returns `true` if the user with the specified `userId` has the specified `relation` to the object of type `objectType` with id `objectId` and `false` otherwise.

```ruby
# Example: user 123 can only view store 824
Warrant::WarrantClient.is_authorized('store', '824', 'view', '123') # true
Warrant::WarrantClient.is_authorized('store', '824', 'edit', '123') # false
```

### `list_warrants(object_type: nil, object_id: nil, relation: nil, user_id: nil)`

This method returns all warrants that match the filters provided, or all warrants for your organization if none are provided. 

```ruby
# List all warrants for an organization
Warrant::WarrantClient.list_warrants

# List all warrants with object type of store
Warrant::WarrantClient.list_warrants(object_type: 'store')
```

We’ve used a random API key in these code examples. Replace it with your [actual publishable API keys](https://app.warrant.dev) to
test this code through your own Warrant account.

For more information on how to use the Warrant API, please refer to the [Warrant API reference](https://docs.warrant.dev).

Note that we may release new [minor and patch](https://semver.org/) versions of this library with small but backwards-incompatible fixes to the type declarations. These changes will not affect Warrant itself.

## Warrant Documentation

- [Warrant Docs](https://docs.warrant.dev/)
