# frozen_string_literal: true

module Warrant
    class ListResponse
        attr_reader :results, :prev_cursor, :next_cursor

        # @!visibility private
        def initialize(results, prev_cursor, next_cursor)
            @results = results
            @prev_cursor = prev_cursor
            @next_cursor = next_cursor
        end
    end
end
