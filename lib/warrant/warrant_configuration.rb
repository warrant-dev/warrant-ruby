# frozen_string_literal: true

module Warrant
    # @!visibility private
    class WarrantConfiguration
        attr_accessor :api_key
        attr_accessor :authorize_endpoint

        attr_reader :api_base, :self_service_dash_url_base

        def initialize
            @api_base = "https://api.warrant.dev"
            @self_service_dash_url_base = "https://self-serve.warrant.dev"
        end
    end
end
