# frozen_string_literal: true

require "warrant/version"

require "net/http"
require "json"
require "forwardable"

require "warrant/models/permission"
require "warrant/models/role"
require "warrant/models/tenant"
require "warrant/models/user"
require "warrant/models/userset"
require "warrant/models/warrant"
require "warrant/warrant_configuration"
require "warrant/warrant_client"

module Warrant
    @config = ::Warrant::WarrantConfiguration.new

    class << self
        extend Forwardable

        attr_reader :config

        def_delegators :@config, :api_key, :api_key=
    end
end
