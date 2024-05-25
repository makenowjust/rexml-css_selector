# frozen_string_literal: true

module REXML
  module CSSSelector
    class BaseAdapter
      def document?(_node)
        false
      end

      def root?(element)
        parent = get_parent_node(element)
        parent.nil? || document?(parent)
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
