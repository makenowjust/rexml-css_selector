# frozen_string_literal: true

module REXML
  module CSSSelector
    module Adapters
      class REXMLAdapter < BaseAdapter
        def element?(node)
          node.instance_of?(::REXML::Element)
        end

        def get_document_node(node)
          node.root_node
        end

        def empty?(node)
          node.children.all? do |child|
            case child
            when ::REXML::Element
              false
            when ::REXML::Text
              child.to_s.match?(/\A\s*\z/)
            else
              true
            end
          end
        end

        def get_tag_name(element)
          element.name
        end

        def get_namespace(element)
          element.prefix
        end

        def get_attribute(element, name, namespace = nil, attribute_name_case = :sensitive)
          namespace = element.namespace(namespace) if namespace

          case attribute_name_case
          in :sensitive
            element.attribute(name, namespace)&.value
          in :insensitive
            name = name.downcase(:ascii)
            target_attr = nil
            element.attributes.each_attribute do |attr|
              if attr.name.downcase(:ascii) == name && (!namespace || attr.namespace == namespace)
                target_attr = attr
                break
              end
            end
            target_attr&.value
          end
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
