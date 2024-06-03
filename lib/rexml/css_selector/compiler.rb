# frozen_string_literal: true

module REXML
  module CSSSelector
    # CompileError is an error on compilation.
    class CompileError < Error
    end

    class PseudoClassDef # :nodoc:
      FIRST_CHILD =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":first-child must not take an argument" if pseudo_class.argument
          Queries::NthChildQuery.new(cont:, a: 0, b: 1)
        end

      LAST_CHILD =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":last-child must not take an argument" if pseudo_class.argument
          Queries::NthLastChildQuery.new(cont:, a: 0, b: 1)
        end

      ONLY_CHILD =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":only-child must not take an argument" if pseudo_class.argument
          Queries::OnlyChildQuery.new(cont:)
        end

      NTH_CHILD =
        PseudoClassDef.new(:nth_of_selector_list) do |cont, pseudo_class, compiler|
          raise CompileError, ":nth-child must take an argument" unless pseudo_class.argument
          case pseudo_class.argument
          in NthOfSelectorList[nth:, selector_list: nil]
            a, b = compiler.nth_value(nth)
            Queries::NthChildQuery.new(cont:, a:, b:)
          in NthOfSelectorList[nth:, selector_list:]
            if selector_list.selectors.any? { _1.is_a?(ComplexSelector) }
              raise CompileError, ":nth-child agument must not take a complex selector"
            end
            a, b = compiler.nth_value(nth)
            query = compiler.compile(selector_list)
            Queries::NthChildOfQuery.new(cont:, a:, b:, query:)
          end
        end

      NTH_LAST_CHILD =
        PseudoClassDef.new(:nth_of_selector_list) do |cont, pseudo_class, compiler|
          raise CompileError, ":nth-last-child must take an argument" unless pseudo_class.argument
          case pseudo_class.argument
          in NthOfSelectorList[nth:, selector_list: nil]
            a, b = compiler.nth_value(nth)
            Queries::NthLastChildQuery.new(cont:, a:, b:)
          in NthOfSelectorList[nth:, selector_list:]
            if selector_list.selectors.any? { _1.is_a?(ComplexSelector) }
              raise CompileError, ":nth-last-child agument must not take a complex selector"
            end
            a, b = compiler.nth_value(nth)
            query = compiler.compile(selector_list)
            Queries::NthLastChildOfQuery.new(cont:, a:, b:, query:)
          end
        end

      FIRST_OF_TYPE =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":first-of-type must not take an argument" if pseudo_class.argument
          Queries::NthOfTypeQuery.new(cont:, a: 0, b: 1)
        end

      LAST_OF_TYPE =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":last-of-type must not take an argument" if pseudo_class.argument
          Queries::NthLastOfTypeQuery.new(cont:, a: 0, b: 1)
        end

      ONLY_OF_TYPE =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":only-of-type must not take an argument" if pseudo_class.argument
          Queries::OnlyOfTypeQuery.new(cont:)
        end

      NTH_OF_TYPE =
        PseudoClassDef.new(:nth) do |cont, pseudo_class, compiler|
          raise CompileError, ":nth-of-type must take an argument" unless pseudo_class.argument
          a, b = compiler.nth_value(pseudo_class.argument)
          Queries::NthOfTypeQuery.new(cont:, a:, b:)
        end

      NTH_LAST_OF_TYPE =
        PseudoClassDef.new(:nth) do |cont, pseudo_class, compiler|
          raise CompileError, ":nth-last-of-type must take an argument" unless pseudo_class.argument
          a, b = compiler.nth_value(pseudo_class.argument)
          Queries::NthLastOfTypeQuery.new(cont:, a:, b:)
        end

      ROOT =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":root must not take an argument" if pseudo_class.argument
          Queries::RootQuery.new(cont:)
        end

      IS =
        PseudoClassDef.new(:selector_list) do |cont, pseudo_class, compiler|
          raise CompileError, ":is must take an argument" unless pseudo_class.argument
          selector_list = pseudo_class.argument
          if selector_list.selectors.any? { _1.is_a?(ComplexSelector) }
            raise CompileError, ":is agument must not take a complex selector"
          end
          query = compiler.compile(selector_list)
          Queries::NestedQuery.new(cont:, query:)
        end

      WHERE =
        PseudoClassDef.new(:selector_list) do |cont, pseudo_class, compiler|
          raise CompileError, ":where must take an argument" unless pseudo_class.argument
          selector_list = pseudo_class.argument
          if selector_list.selectors.any? { _1.is_a?(ComplexSelector) }
            raise CompileError, ":where agument must not take a complex selector"
          end
          query = compiler.compile(selector_list)
          Queries::NestedQuery.new(cont:, query:)
        end

      NOT =
        PseudoClassDef.new(:selector_list) do |cont, pseudo_class, compiler|
          raise CompileError, ":not must take an argument" unless pseudo_class.argument
          selector_list = pseudo_class.argument
          if selector_list.selectors.any? { _1.is_a?(ComplexSelector) }
            raise CompileError, ":not agument must not take a complex selector"
          end
          query = compiler.compile(selector_list)
          Queries::NotQuery.new(cont:, query:)
        end

      SCOPE =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":scope must not take an argument" if pseudo_class.argument
          Queries::ScopeQuery.new(cont:)
        end

      HAS =
        PseudoClassDef.new(:relative_selector_list) do |cont, pseudo_class, compiler|
          raise CompileError, ":has must take an argument" unless pseudo_class.argument
          relative_selector_list = pseudo_class.argument
          needs_parent = false
          selectors =
            relative_selector_list.selectors.map do |relative_selector|
              scope =
                CompoundSelector[
                  type: nil,
                  subclasses: [PseudoClass[name: "scope", argument: nil]],
                  pseudo_elements: []
                ]
              case relative_selector.combinator
              when :sibling, :adjacent
                needs_parent = true
              end
              ComplexSelector[left: scope, combinator: relative_selector.combinator, right: relative_selector.right]
            end
          query = compiler.compile(SelectorList[selectors:])
          Queries::HasQuery.new(cont:, query:, needs_parent:)
        end

      EMPTY =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":empty must not take an argument" if pseudo_class.argument
          Queries::EmptyQuery.new(cont:)
        end

      CHECKED =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":checked must not take an argument" if pseudo_class.argument
          Queries::CheckedQuery.new(cont:)
        end

      DISABLED =
        PseudoClassDef.new do |cont, pseudo_class, _compiler|
          raise CompileError, ":disabled must not take an argument" if pseudo_class.argument
          Queries::DisabledQuery.new(cont:)
        end
    end

    # Compiler is a compiler from selectors to queries.
    class Compiler
      def initialize(**config)
        @config = config
        @config[:pseudo_classes] ||= {}
      end

      def compile(selector_list)
        compile_selector_list(selector_list)
      end

      def namespace_name(namespace)
        case namespace
        in Namespace[name:]
          name
        in UniversalNamespace[] | nil
          nil
        end
      end

      def nth_value(nth)
        case nth
        in Nth[a:, b:]
          [a, b]
        in Odd[]
          [2, 1]
        in Even[]
          [2, 0]
        end
      end

      private

      def compile_selector_list(selector_list)
        queries = selector_list.selectors.map { compile_complex_selector(_1) }
        return queries.first if queries.size == 1
        Queries::OneOfQuery.new(conts: queries)
      end

      def compile_complex_selector(selector)
        cont = Queries::TrueQuery::INSTANCE
        loop do
          return compile_compound_selector(cont, selector) if selector.is_a?(CompoundSelector)

          cont = compile_compound_selector(cont, selector.left)
          cont = compile_combinator(cont, selector.combinator)
          selector = selector.right
        end
      end

      def compile_compound_selector(cont, selector)
        cont = compile_type_selector(cont, selector.type) if selector.type

        selector.subclasses.each { |subclass| cont = compile_subclass_selector(cont, subclass) }

        raise CompileError, "pseudo elements are not supported" unless selector.pseudo_elements.empty?

        cont
      end

      def compile_type_selector(cont, type)
        case type
        in TagNameType[namespace:, tag_name:]
          namespace = namespace_name(namespace)
          Queries::TagNameTypeQuery.new(cont:, tag_name:, namespace:)
        in UniversalType[namespace:]
          namespace = namespace_name(namespace)
          Queries::UniversalTypeQuery.new(cont:, namespace:)
        end
      end

      def compile_subclass_selector(cont, subclass)
        case subclass
        in ClassName[name:]
          Queries::ClassNameQuery.new(cont:, name:)
        in Id[name:]
          Queries::IdQuery.new(cont:, name:)
        in Attribute[namespace:, name:, matcher: nil, value: nil, modifier: nil]
          namespace = namespace_name(namespace)
          Queries::AttributePresenceQuery.new(cont:, name:, namespace:)
        in Attribute[namespace:, name:, matcher:, value:, modifier:]
          namespace = namespace_name(namespace)
          Queries::AttributeMatcherQuery.new(cont:, name:, namespace:, matcher:, value:, modifier:)
        in PseudoClass[name:] => pseudo_class
          pseudo_class_def = @config[:pseudo_classes][name.downcase(:ascii)]
          raise CompileError, "undefined pseudo class ':#{name}'" unless pseudo_class_def
          pseudo_class_def.compile(cont, pseudo_class, self)
        end
      end

      def compile_combinator(cont, combinator)
        case combinator
        in :descendant
          Queries::DescendantQuery.new(cont:)
        in :sibling
          Queries::SiblingQuery.new(cont:)
        in :adjacent
          Queries::AdjacentQuery.new(cont:)
        in :child
          Queries::ChildQuery.new(cont:)
        in :column
          raise CompileError, "column combinator is not supported"
        end
      end
    end
  end
end
