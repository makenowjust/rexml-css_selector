# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class DeferredResult
        def initialize
          @is_match = false
        end

        attr_accessor :is_match
      end

      class DescendantQuery
        def initialize(cont:)
          @cont = cont
        end

        def call(node, context)
          cache = context.cache
          result = nil

          while (node = context.adapter.get_parent_node(node))
            cached = cache[[object_id, node.object_id]]
            if cached.nil?
              result ||= DeferredResult.new
              result.is_match = @cont.call(node, context)
              cache[[object_id, node.object_id]] = result
              return true if result.is_match
            else
              result&.is_match = cached.is_match
              return cached.is_match
            end
          end

          false
        end
      end
    end
  end
end
