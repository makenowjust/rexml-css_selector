# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class CheckedQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          (context.adapter.checked?(node) || context.options[:checked_elements].include?(node)) &&
            @cont.call(node, context)
        end
      end
    end
  end
end
