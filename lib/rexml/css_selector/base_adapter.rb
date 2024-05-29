# frozen_string_literal: true

module REXML
  module CSSSelector
    # BaseAdapter is a base class of adapters.
    #
    # An adapter is an abstraction of tree traversal operations for CSS selectors.
    # We need to implement the following methods minimally:
    #
    # - <tt>element?(node)</tt>
    # - <tt>get_tag_name(element)</tt>
    # - <tt>get_namespace(element)</tt>
    # - <tt>get_attribute(element, name, namespace = nil, attribute_name_case = :sensitive)</tt>
    # - <tt>get_document_node(element)</tt>
    # - <tt>get_parent_node(element)</tt>
    # - <tt>get_previous_sibling_node(element)</tt>
    # - <tt>each_child_element(element, &)</tt>
    class BaseAdapter
      # Checks whether +element+ is the root element.
      #
      # This method is used for <tt>:root</tt>.
      def root?(element)
        get_parent_node(element) == get_document_node(element)
      end

      # Checks whether +element+ is empty.
      #
      # This method is used for <tt>:empty</tt>.
      def empty?(element)
        each_child_element(element) { return false }
        true
      end

      # Checks whether +element+ is checked.
      #
      # This method is used for <tt>:checked</tt>.
      def checked?(element)
        !!get_attribute(element, "checked")
      end

      # Checks whether +element+ is disabled.
      #
      # This method is used for <tt>:disabled</tt>.
      def disabled?(element)
        !!get_attribute(element, "disabled")
      end

      # Returns an array of children elements of +element+.
      def get_children_elements(element)
        elements = []
        each_child_element(element) { elements << _1 }
        elements
      end

      # Returns the index of +element+ in the children of +parent+.
      def get_element_index(parent, element)
        i = 0
        each_child_element(parent) do |child|
          return i if element == child
          i += 1
        end
        nil
      end

      # Returns class names of +element+.
      def get_class_names(element)
        get_attribute(element, "class")&.split(/\s+/) || []
      end

      # Returns the ID name of +element+.
      def get_id(element)
        get_attribute(element, "id")
      end

      # Enumerates the elements in +element+
      def each_recursive_element(element, &)
        each_child_element(element) do |child|
          yield child
          each_recursive_element(child, &)
        end
      end
    end
  end
end
