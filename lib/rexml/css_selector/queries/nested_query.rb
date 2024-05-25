# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class NestedQuery
        def initialize(cont:, query:)
          @cont = cont
          @query = query
        end

        def call(node, context)
          @query.call(node, context) && @cont.call(node, context)
        end
      end
    end
  end
end
