# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class HasQuery
        def initialize(cont:, query:, needs_parent:)
          @cont = cont
          @query = query
          @needs_parent = needs_parent
        end

        def call(node, context)
          matched = false
          context.scoped(node) do
            base = node
            base = context.adapter.get_parent_node(base) if @needs_parent
            context
              .adapter
              .each_recursive_node(base) do |child|
                next if node == child
                if @query.call(child, context)
                  matched = true
                  break
                end
              end
          end

          matched && @cont.call(node, context)
        end
      end
    end
  end
end
