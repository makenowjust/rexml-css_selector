# frozen_string_literal: true

module REXML
  module CSSSelector
    class BaseAdapter
      def root?(element)
        get_parent_node(element) == get_document_node(element)
      end

      def checked?(element)
        !!get_attribute(element, "checked")
      end

      def disabled?(element)
        !!get_attribute(element, "disabled")
      end

      def get_element_index(parent, element)
        get_children_elements(parent).index(element)
      end

      def get_class_names(element)
        get_attribute(element, "class")&.split(/\s+/) || []
      end

      def get_id(element)
        get_attribute(element, "id")
      end
    end
  end
end
