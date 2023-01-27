# frozen_string_literal: true

module Warrant
    class WarrantQuery
        attr_accessor :select_clause, :for_clause, :where_clause

        def initialize
            @select_clause = []
            @for_clause = {}
            @where_clause = {}
        end

        def select(*object_types)
            @select_clause = object_types
            self
        end

        def select_explicit(*object_types)
            @select_clause = "explicit #{object_types}"
            self
        end

        def for(for_filters)
            @for_clause = @for_clause.merge(for_filters)
            self
        end

        def where(where_filters)
            @where_clause = @where_clause.merge(where_filters)
            self
        end

        def to_query_param
            if @select_clause.length == 0 || @for_clause.empty?
                raise "Must have a select and for clause"
            end

            query = "SELECT #{@select_clause.join(",")} FOR #{filters_hash_to_string(@for_clause)}"
            query += " WHERE #{filters_hash_to_string(@where_clause)}" unless @where_clause.empty?

            query
        end

        private

        def filters_hash_to_string(filters)
            filter_string = ""

            if filters[:object]
                filter_string += "object=#{filters[:object]}"
            elsif filters[:subject]
                filter_string += "subject=#{filters[:subject]}"
            end

            if filters[:context]
                context_values = []
                filters[:context].each{ |k, v|
                    context_values.push("#{k}=#{v}")
                }

                filter_string += " AND context=[#{context_values.join(" ")}]"
            end

            filter_string
        end
    end
end
