# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class OnlyChildQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          return false unless context.adapter.element?(node)

          parent = context.adapter.get_parent_node(node)
          return false unless parent

          children = context.adapter.get_children_elements(parent)
          children.size == 1 && @cont.call(node, context)
        end
      end
    end
  end
end
