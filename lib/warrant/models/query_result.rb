# frozen_string_literal: true

module Warrant
  class QueryResult
      attr_accessor :object_type, :object_id, :warrant, :is_implicit, :meta

      # @!visibility private
      def initialize(object_type, object_id, warrant, is_implicit, meta)
        @object_type = object_type
        @object_id = object_id
        @warrant = warrant
        @is_implicit = is_implicit
        @meta = meta
      end
  end
end
