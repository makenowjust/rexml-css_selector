# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class TrueQuery
        def call(_node, _context)
          true
        end

        INSTANCE = new
      end
    end
  end
end
