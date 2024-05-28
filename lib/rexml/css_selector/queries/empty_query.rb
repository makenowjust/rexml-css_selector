# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class EmptyQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          context.adapter.empty?(node) && @cont.call(node, context)
        end
      end
    end
  end
end
