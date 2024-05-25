# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class ScopeQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          node == context.scope && @cont.call(node, context)
        end
      end
    end
  end
end
