# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class ChildQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          node = context.adapter.get_parent_node(node)
          context.adapter.element?(node) && @cont.call(node, context)
        end
      end
    end
  end
end
