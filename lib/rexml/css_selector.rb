# frozen_string_literal: true

require "rexml/document"
require "strscan"

module REXML
  module CSSSelector
    class Error < ::StandardError
    end
  end
end

require_relative "css_selector/version"

require_relative "css_selector/ast"
require_relative "css_selector/base_adapter"
require_relative "css_selector/parser"
require_relative "css_selector/pseudo_class_def"
require_relative "css_selector/query_context"

require_relative "css_selector/adapters/rexml_adapter"

require_relative "css_selector/queries/adjacent_query"
require_relative "css_selector/queries/attribute_matcher_query"
require_relative "css_selector/queries/attribute_presence_query"
require_relative "css_selector/queries/child_query"
require_relative "css_selector/queries/class_name_query"
require_relative "css_selector/queries/descendant_query"
require_relative "css_selector/queries/has_query"
require_relative "css_selector/queries/id_query"
require_relative "css_selector/queries/nested_query"
require_relative "css_selector/queries/nth_child_of_query"
require_relative "css_selector/queries/nth_child_query"
require_relative "css_selector/queries/nth_last_child_of_query"
require_relative "css_selector/queries/nth_last_child_query"
require_relative "css_selector/queries/nth_last_of_type_query"
require_relative "css_selector/queries/nth_of_type_query"
require_relative "css_selector/queries/not_query"
require_relative "css_selector/queries/only_child_query"
require_relative "css_selector/queries/only_of_type_query"
require_relative "css_selector/queries/one_of_query"
require_relative "css_selector/queries/root_query"
require_relative "css_selector/queries/scope_query"
require_relative "css_selector/queries/sibling_query"
require_relative "css_selector/queries/tag_name_type_query"
require_relative "css_selector/queries/true_query"
require_relative "css_selector/queries/universal_type_query"

require_relative "css_selector/compiler"

module REXML
  module CSSSelector
    def self.each_select(
      scope,
      selector,
      pseudo_classes: {},
      adapter: Adapters::REXMLAdapter::INSTANCE,
      substitutions: {},
      options: {}
    )
      pseudo_classes.transform_values(&:argument_kind)
      selector = Parser.new(selector, pseudo_class_functions: {}).parse
      query = Compiler.new(pseudo_classes:).compile(selector)
      context = QueryContext.new(scope:, substitutions:, adapter:, options:)
      adapter.each_recursive_node(scope) { |node| yield node if query.call(node, context) }
      nil
    end

    def self.select(
      scope,
      selector,
      pseudo_classes: {},
      adapter: Adapters::REXMLAdapter::INSTANCE,
      substitutions: {},
      options: {}
    )
      each_select(scope, selector, pseudo_classes:, adapter:, substitutions:, options:) { |node| break node }
    end

    def self.select_all(
      scope,
      selector,
      pseudo_classes: {},
      adapter: Adapters::REXMLAdapter::INSTANCE,
      substitutions: {},
      options: {}
    )
      elements = []
      each_select(scope, selector, pseudo_classes:, adapter:, substitutions:, options:) { |node| elements << node }
      elements
    end
  end
end
