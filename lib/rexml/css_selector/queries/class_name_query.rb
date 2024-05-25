# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class ClassNameQuery
        def initialize(cont:, name:)
          @cont = cont
          @name = name
        end

        def call(node, context)
          context.adapter.get_class_names(node).include?(@name) && @cont.call(node, context)
        end
      end
    end
  end
end
