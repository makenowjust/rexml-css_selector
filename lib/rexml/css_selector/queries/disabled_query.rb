# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class DisabledQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          (context.adapter.disabled?(node) || context.options[:disabled_elements].include?(node)) &&
            @cont.call(node, context)
        end
      end
    end
  end
end
