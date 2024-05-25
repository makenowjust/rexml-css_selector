# frozen_string_literal: true

module REXML
  module CSSSelector
    module Adapters
      class REXMLAdapter < BaseAdapter
        def document?(node)
          node.is_a?(::REXML::Document)
        end

        def element?(node)
          node.is_a?(::REXML::Element)
        end

        def get_tag_name(element)
          element.name
        end

        def get_namespace(element)
          element.prefix
        end

        def get_attribute(element, name, namespace = nil)
          if namespace
            namespace = element.namespace(namespace)
            return nil unless namespace
          end
          element.attribute(name, namespace)&.value
        end

        def get_parent_node(element)
          element.parent
        end

        def get_previous_sibling_element(element)
          element.previous_element
        end

        def get_children_elements(element)
          element.children.filter { element?(_1) }
        end

        def each_child_node(element, &)
          element.each_child(&)
        end

        def each_recursive_node(element, &)
          element.each_recursive(&)
        end

        INSTANCE = new
      end
    end
  end
end
