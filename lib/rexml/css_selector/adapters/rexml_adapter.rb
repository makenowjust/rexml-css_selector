# frozen_string_literal: true

module REXML
  module CSSSelector
    module Adapters
      # REXMLAdapter is an adapter implementation for +REXML+.
      class REXMLAdapter < BaseAdapter
        def element?(node)
          node.instance_of?(::REXML::Element)
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
            attrs = element.attributes
            # NOTE: `REXML::Element.attribute` is too slow to use.
            # Therefore, we call `REXML::Attributes#[]` instead.
            namespace.nil? ? attrs[name] : attrs.get_attribute_ns(namespace, name)&.value
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

        def get_document_node(node)
          node.root_node
        end

        def get_parent_node(element)
          element.parent
        end

        def get_previous_sibling_element(element)
          element.previous_element
        end

        def each_child_element(element, &)
          return unless element.is_a?(::REXML::Element)
          element.each_child { yield _1 if element?(_1) }
        end

        # NOTE: `REXML::Element#each_recursive` is too slow.
        # Therefore, we use our default implementation instead.

        # INSTANCE is the default instance.
        INSTANCE = new
      end
    end
  end
end
