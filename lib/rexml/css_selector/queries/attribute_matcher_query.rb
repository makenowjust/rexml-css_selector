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

          name = @name
          name = @name.downcase(:ascii) if context.options[:attribute_name_case] == :insensitive
          actual = context.adapter.get_attribute(node, name, @namespace, context.options[:attribute_name_case])
          return false unless actual

          if @modifier == :i || context.options[:case_sensitive_attribute_values].include?(name)
            value = value.downcase(:ascii)
            actual = actual.downcase(:ascii)
          end

          case @matcher
          in :"="
            value == actual && @cont.call(node, context)
          in :"~="
            actual.split(/\s+/).include?(value) && @cont.call(node, context)
          in :"|="
            /(?:^|\|)#{value}(?:$|[|-])/.match?(actual) && @cont.call(node, context)
          in :"^="
            # From https://www.w3.org/TR/selectors-3/#attribute-substrings.
            # > If "val" is the empty string then the selector does not represent anything.
            !value.empty? && actual.start_with?(value) && @cont.call(node, context)
          in :"$="
            # From https://www.w3.org/TR/selectors-3/#attribute-substrings.
            # > If "val" is the empty string then the selector does not represent anything.
            !value.empty? && actual.end_with?(value) && @cont.call(node, context)
          in :"*="
            # From https://www.w3.org/TR/selectors-3/#attribute-substrings.
            # > If "val" is the empty string then the selector does not represent anything.
            !value.empty? && actual.include?(value) && @cont.call(node, context)
          end
        end
      end
    end
  end
end
