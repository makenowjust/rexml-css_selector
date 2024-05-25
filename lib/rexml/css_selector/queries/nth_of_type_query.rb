# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class NthOfTypeQuery
        def initialize(cont:, a:, b:)
          @cont = cont
          @a = a
          @b = b
        end

        def call(node, context)
          return false unless context.adapter.element?(node)

          parent = context.adapter.get_parent_node(node)
          return false unless parent

          insensitive = context.options[:tag_name_case] == :insensitive
          tag_name = context.adapter.get_tag_name(node)
          tag_name = tag_name.downcase(:ascii) if insensitive

          children = context.adapter.get_children_elements(parent)
          children =
            children.filter do |child|
              child_tag_name = context.adapter.get_tag_name(child)
              child_tag_name = child_tag_name.downcase(:ascii) if insensitive
              tag_name == child_tag_name
            end

          index = children.index(node)
          return false unless index
          index += 1

          if @a.zero?
            index == @b && @cont.call(node, context)
          else
            ((index - @b) % @a).zero? && (index - @b) / @a >= 0 && @cont.call(node, context)
          end
        end
      end
    end
  end
end
