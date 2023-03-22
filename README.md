# Warrant Ruby Library

Use [Warrant](https://warrant.dev/) in ruby projects.

[![Gem Version](https://badge.fury.io/rb/warrant.svg)](https://badge.fury.io/rb/warrant)
[![Slack](https://img.shields.io/badge/slack-join-brightgreen)](https://join.slack.com/t/warrantcommunity/shared_invite/zt-12g84updv-5l1pktJf2bI5WIKN4_~f4w)

## Installation
---

Add this line to your application's Gemfile:

```ruby
gem 'warrant'
```

And then execute:

    $ bundle install

Or install it yourself:

    $ gem install warrant

You can also build the gem from source:

    $ gem build warrant.gemspec

## Documentation
---

- [Ruby API Docs](https://rubydoc.info/gems/warrant)
- [Warrant Docs](https://docs.warrant.dev/)

## Requirements
---

- Ruby 2.3+.

## Usage
---

```ruby
require 'warrant'
Warrant.api_key = 'api_test_f5dsKVeYnVSLHGje44zAygqgqXiLJBICbFzCiAg1E='

# Create a user
Warrant::User.create(user_id: "user123")

# Check whether user slp951 has view access to report 7asm24
Warrant::Warrant.is_authorized?(object_type: "report", object_id: "7asm24", relation: "viewer", subject: { object_id: "user", object_id: "slp951" })
```

## Configuring the API and Authorize Endpoints
---
The API and Authorize endpoints the SDK makes requests to is configurable via the `Warrant.api_base` and `Warrant.authorize_endpoint` attributes:

```ruby
require 'warrant'

# Set api and authorize endpoints to http://localhost:8000
Warrant.api_base = 'http://localhost:8000'
Warrant.authorize_endpoint = 'http://localhost:8000'
```

## Configuring SSL
---
By default, the SDK will attempt to use SSL when making requests to the API. This setting is configurable via the `Warrant.use_ssl` attribute:

```ruby
require 'warrant'

# Disable ssl
Warrant.use_ssl = false
```


We’ve used a random API key in these code examples. Replace it with your [actual publishable API keys](https://app.warrant.dev) to
test this code through your own Warrant account.

For more information on how to use the Warrant API, please refer to the [Warrant API reference](https://docs.warrant.dev).

Note that we may release new [minor and patch](https://semver.org/) versions of this library with small but backwards-incompatible fixes to the type declarations. These changes will not affect Warrant itself.
