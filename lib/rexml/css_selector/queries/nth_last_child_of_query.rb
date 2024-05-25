# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class NthLastChildOfQuery
        def initialize(cont:, a:, b:, query:)
          @cont = cont
          @a = a
          @b = b
          @query = query
        end

        def call(node, context)
          return false unless context.adapter.element?(node)

          parent = context.adapter.get_parent_node(node)
          return false unless parent

          matched_children = context.cache[[object_id, parent.object_id]]
          unless matched_children
            children = context.adapter.get_children_elements(parent)
            matched_children = children.filter { @query.call(_1, context) }
            context.cache[[object_id, parent.object_id]] = matched_children
          end

          index = matched_children.index(node)
          return false unless index
          index = matched_children.size - index

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
