# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class NthLastChildQuery
        def initialize(cont:, a:, b:)
          @cont = cont
          @a = a
          @b = b
        end

        def call(node, context)
          return false unless context.adapter.element?(node)

          parent = context.adapter.get_parent_node(node)
          return false unless parent

          children_size = context.adapter.get_children_elements(parent).size
          index = context.adapter.get_element_index(parent, node)
          return false unless index
          index = children_size - index

          if @a.zero?
            index == @b && @cont.call(node, context)
          else
            ((index - @b) % @a).zero? && (index - @b) / @a >= 0 && @cont.call(node, context)
          end
        end
      end
    end
  end
end
