# frozen_string_literal: true

require "rexml/document"
require "set"
require "strscan"

module REXML
  module CSSSelector
    # Error is a base class of errors in this library.
    class Error < ::StandardError
    end
  end
end

require_relative "css_selector/ast"
require_relative "css_selector/base_adapter"
require_relative "css_selector/parser"
require_relative "css_selector/pseudo_class_def"
require_relative "css_selector/query_context"
require_relative "css_selector/version"

require_relative "css_selector/adapters/rexml_adapter"

require_relative "css_selector/queries/adjacent_query"
require_relative "css_selector/queries/attribute_matcher_query"
require_relative "css_selector/queries/attribute_presence_query"
require_relative "css_selector/queries/checked_query"
require_relative "css_selector/queries/child_query"
require_relative "css_selector/queries/class_name_query"
require_relative "css_selector/queries/descendant_query"
require_relative "css_selector/queries/disabled_query"
require_relative "css_selector/queries/empty_query"
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
  # CSSSelector provides CSS selector matching for +REXML+.
  module CSSSelector
    # DEFAULT_CONFIG is the default configuration value.
    DEFAULT_CONFIG = {
      pseudo_classes: {
        "first-child" => PseudoClassDef::FIRST_CHILD,
        "last-child" => PseudoClassDef::LAST_CHILD,
        "only-child" => PseudoClassDef::ONLY_CHILD,
        "nth-child" => PseudoClassDef::NTH_CHILD,
        "nth-last-child" => PseudoClassDef::NTH_LAST_CHILD,
        "first-of-type" => PseudoClassDef::FIRST_OF_TYPE,
        "last-of-type" => PseudoClassDef::LAST_OF_TYPE,
        "only-of-type" => PseudoClassDef::ONLY_OF_TYPE,
        "nth-of-type" => PseudoClassDef::NTH_OF_TYPE,
        "nth-last-of-type" => PseudoClassDef::NTH_LAST_OF_TYPE,
        "root" => PseudoClassDef::ROOT,
        "is" => PseudoClassDef::IS,
        "where" => PseudoClassDef::WHERE,
        "not" => PseudoClassDef::NOT,
        "scope" => PseudoClassDef::SCOPE,
        "has" => PseudoClassDef::HAS,
        "empty" => PseudoClassDef::EMPTY,
        "checked" => PseudoClassDef::CHECKED,
        "disabled" => PseudoClassDef::DISABLED
      }.freeze,
      adapter: Adapters::REXMLAdapter::INSTANCE,
      substitutions: {}.freeze,
      options: {
        tag_name_case: :sensitive,
        attribute_name_case: :sensitive,
        case_sensitive_attribute_values: [].freeze,
        checked_elements: [].freeze,
        disabled_elements: [].freeze
      }.freeze
    }.freeze

    # HTML_OPTIONS is a set of options.
    #
    # This value is used when <tt>html: true</tt> is specified.
    HTML_OPTIONS = {
      tag_name_case: :insensitive,
      attribute_name_case: :insensitive,
      # See https://html.spec.whatwg.org/multipage/semantics-other.html#case-sensitivity-of-selectors.
      case_sensitive_attribute_values:
        Set[
          *%w[
            accept
            accept-charset
            align
            alink
            axis
            bgcolor
            charset
            checked
            clear
            codetype
            color
            compact
            declare
            defer
            dir
            direction
            disabled
            enctype
            face
            frame
            hreflang
            http-equiv
            lang
            language
            link
            media
            method
            multiple
            nohref
            noresize
            noshade
            nowrap
            readonly
            rel
            rev
            rules
            scope
            scrolling
            selected
            shape
            target
            text
            type
            valign
            valuetype
            vlink
          ]
        ].freeze,
      checked_elements: [].freeze,
      disabled_elements: [].freeze
    }.freeze

    def self.setup_config(config) # :nodoc:
      pseudo_classes = DEFAULT_CONFIG[:pseudo_classes]
      pseudo_classes = pseudo_classes.merge(config[:pseudo_classes]) if config[:pseudo_classes]

      adapter = config[:adapter] || DEFAULT_CONFIG[:adapter]

      substitutions = DEFAULT_CONFIG[:substitutions]
      substitutions = substitutions.merge(config[:substitutions]) if config[:substitutions]

      options = config[:html] ? HTML_OPTIONS : DEFAULT_CONFIG[:options]
      options = options.merge(config[:options]) if config[:options]

      [pseudo_classes, adapter, substitutions, options]
    end

    def self.is(node, selector, scope: nil, **config)
      pseudo_classes, adapter, substitutions, options = setup_config(config)
      scope ||= adapter.get_document_node(node)
      selector = Parser.new(pseudo_classes:).parse(selector)
      query = Compiler.new(pseudo_classes:).compile(selector)
      context = QueryContext.new(scope:, adapter:, substitutions:, options:)
      query.call(node, context)
    end

    def self.each_select(scope, selector, **config)
      pseudo_classes, adapter, substitutions, options = setup_config(config)
      selector = Parser.new(pseudo_classes:).parse(selector)
      query = Compiler.new(pseudo_classes:).compile(selector)
      context = QueryContext.new(scope:, adapter:, substitutions:, options:)
      adapter.each_recursive_element(scope) { yield _1 if query.call(_1, context) }
      nil
    end

    def self.select(scope, selector, **config)
      each_select(scope, selector, **config) { |node| break node }
    end

    def self.select_all(scope, selector, **config)
      elements = []
      each_select(scope, selector, **config) { |node| elements << node }
      elements
    end
  end
end
