# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class RootQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          context.adapter.element?(node) && context.adapter.root?(node) && @cont.call(node, context)
        end
      end
    end
  end
end
