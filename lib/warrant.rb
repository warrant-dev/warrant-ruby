# frozen_string_literal: true

require "warrant/version"

require "net/http"
require "json"
require "forwardable"

require "warrant/warrant_object"
require "warrant/warrant_query"

require "warrant/api_operations"
require "warrant/errors"
require "warrant/models/feature"
require "warrant/models/permission"
require "warrant/models/pricing_tier"
require "warrant/models/role"
require "warrant/models/session"
require "warrant/models/subject"
require "warrant/models/tenant"
require "warrant/models/user"
require "warrant/models/warrant"
require "warrant/util"
require "warrant/warrant_configuration"

module Warrant
    @config = ::Warrant::WarrantConfiguration.new

    class << self
        extend Forwardable

        attr_reader :config

        def_delegators :@config, :api_key, :api_key=, :api_base, :api_base=, :authorize_endpoint, :authorize_endpoint=
    end
end
