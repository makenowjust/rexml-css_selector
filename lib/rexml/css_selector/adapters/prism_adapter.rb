# frozen_string_literal: true

require "prism"

module REXML
  module CSSSelector
    module Adapters
      class PrismAdapter < BaseAdapter
        class PrismDOM
          def initialize(node, parent: nil, document: nil, index: 0)
            @node = node
            @parent = parent
            @document = document || self
            @index = index
          end

          attr_reader :node, :parent, :document

          def type
            @node.type.to_s.gsub(/_node$/, "")
          end

          def attribute(name)
            @node.deconstruct_keys([])[name.intern]&.to_s
          end

          def children
            @children ||=
              begin
                children = []
                @node.compact_child_nodes.each_with_index do |child, index|
                  children << PrismDOM.new(child, parent: self, document:, index:)
                end
                children
              end
          end

          def previous_sibling
            return if index.zero?
            parent.children[index - 1]
          end
        end

        def element?(node)
          node.is_a?(PrismDOM)
        end

        def get_tag_name(element)
          element.type
        end

        def get_attribute(element, name, _namespace = nil, _attribute_name_case = :sensitive)
          element.attribute(name)
        end

        def get_document_node(element)
          element.document
        end

        def get_parent_node(element)
          element.parent
        end

        def get_previous_sibling_element(element)
          element.previous_sibling
        end

        def each_child_element(element, &)
          element.children.each(&)
        end

        # INSTANCE is the default instance.
        INSTANCE = new
      end
    end
  end
end
