# frozen_string_literal: true

module REXML
  module CSSSelector
    module Queries
      class TagNameTypeQuery
        def initialize(cont:, tag_name:, namespace:)
          @tag_name = tag_name
          @namespace = namespace
          @cont = cont
        end

        def call(node, context)
          return false unless context.adapter.element?(node)

          return false if @namespace && context.adapter.get_namespace(node) != @namespace

          tag_name = context.adapter.get_tag_name(node)
          case context.options[:tag_name_case]
          in nil | :sensitive
            tag_name == @tag_name && @cont.call(node, context)
          in :insensitive
            tag_name = tag_name.downcase(:ascii)
            tag_name == @tag_name.downcase(:ascii) && @cont.call(node, context)
          end
        end
      end
    end
  end
end
