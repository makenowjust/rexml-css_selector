# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class IdQuery
        def initialize(cont:, name:)
          @cont = cont
          @name = name
        end

        def call(node, context)
          context.adapter.get_id(node) == @name && @cont.call(node, context)
        end
      end
    end
  end
end
