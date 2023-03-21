# frozen_string_literal: true

module Warrant
    # @!visibility private
    class WarrantConfiguration
        attr_accessor :api_key, :api_base, :authorize_endpoint, :use_ssl

        attr_reader :self_service_dash_url_base

        def initialize
            @api_key = ""
            @api_base = "https://api.warrant.dev"
            @authorize_endpoint = "https://api.warrant.dev"
            @self_service_dash_url_base = "https://self-serve.warrant.dev"
            @use_ssl = true
        end
    end
end
