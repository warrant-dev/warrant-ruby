# frozen_string_literal: true

require "warrant/version"


require "warrant/models/user"
require "warrant/models/userset"
require "warrant/models/user_warrant"
require "warrant/models/userset_warrant"
require "warrant/warrant_configuration"

module Warrant
    @config = Warrant::WarrantConfiguration.new

    class << self
        extend Forwardable

        attr_reader :config

        def_delegators :@config, :api_key, :api_key=
    end
end
