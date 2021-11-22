# frozen_string_literal: true

module Warrant
    class WarrantConfiguration
        attr_accessor :api_key

        attr_reader :api_base

        def initialize
            @api_base = "https://api.warrant.dev"
        end
    end
end
