# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class SiblingQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          while (node = context.adapter.get_previous_sibling_element(node))
            return true if context.adapter.element?(node) && @cont.call(node, context)
          end

          false
        end
      end
    end
  end
end
