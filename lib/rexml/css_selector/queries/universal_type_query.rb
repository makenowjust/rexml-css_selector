# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class UniversalTypeQuery
        def initialize(cont:, namespace:)
          @namespace = namespace
          @cont = cont
        end

        def call(node, context)
          return false unless context.adapter.element?(node)

          return false if @namespace && context.adapter.get_namespace(node) != @namespace

          @cont.call(node, context)
        end
      end
    end
  end
end
