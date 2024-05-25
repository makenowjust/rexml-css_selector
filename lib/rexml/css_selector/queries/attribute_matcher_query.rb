# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class AttributeMatcherQuery
        def initialize(cont:, name:, namespace:, matcher:, value:, modifier:)
          @cont = cont
          @name = name
          @namespace = namespace
          @matcher = matcher
          @value = value
          @modifier = modifier
        end

        def call(node, context)
          value =
            case @value
            in Substitution[name:]
              context.substitutions[name]
            in String[value:]
              value
            in Ident[value:]
              value
            in Bare[value:]
              value
            end
          return false unless value

          actual = context.adapter.get_attribute(node, @name, @namespace)
          return false unless actual

          if @modifier == :i
            value = value.downcase(:ascii)
            actual = actual.downcase(:ascii)
          end

          case @matcher
          in :"="
            value == actual && @cont.call(node, context)
          in :"~="
            actual.split(/\s+/).include?(value) && @cont.call(node, context)
          in :"|="
            /(?:^|\|)#{value}(?:$|\||-)/.match?(actual) && @cont.call(node, context)
          in :"^="
            actual.start_with?(value) && @cont.call(node, context)
          in :"$="
            actual.end_with?(value) && @cont.call(node, context)
          in :"*="
            actual.include?(value) && @cont.call(node, context)
          end
        end
      end
    end
  end
end
