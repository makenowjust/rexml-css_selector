# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class AttributePresenceQuery
        def initialize(cont:, name:, namespace:)
          @cont = cont
          @name = name
          @namespace = namespace
        end

        def call(node, context)
          context.adapter.get_attribute(node, @name, @namespace, context.options[:attribute_name_case]) &&
            @cont.call(node, context)
        end
      end
    end
  end
end
