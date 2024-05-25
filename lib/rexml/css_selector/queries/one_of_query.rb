# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class OneOfQuery
        def initialize(conts:)
          @conts = conts
        end

        def call(node, context)
          @conts.any? { |cont| cont.call(node, context) }
        end
      end
    end
  end
end
