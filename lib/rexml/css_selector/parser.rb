# frozen_string_literal: true

module REXML
  module CSSSelector
    # ParseError is an error on parsing.
    class ParseError < Error
      def initialize(message, pos)
        super("#{message} (at #{pos})")
      end
    end

    # Parser is a CSS selector parser.
    class Parser
      def initialize(**config)
        @config = config
        @config[:pseudo_classes] ||= {}
      end

      def parse(source)
        old_scanner = @scanner
        @scanner = StringScanner.new(source)
        @scanner.scan RE_WS
        parse_selector_list
      ensure
        @scanner = old_scanner
      end

      # See https://www.w3.org/TR/css-syntax-3/#token-diagrams and https://www.w3.org/TR/css-syntax-3/#tokenizer-definitions.

      # :stopdoc:

      RE_NEWLINE = /\r\n|[\n\r\f]/
      RE_WHITESPACE = /#{RE_NEWLINE}|[ \t]/
      RE_WS = /(?:#{RE_WHITESPACE})*/
      RE_ESCAPE = /\\(?:(?!#{RE_NEWLINE})\H|\h{1,6}(?:#{RE_WHITESPACE})?)/
      RE_ESCAPE_NEWLINE = /#{RE_ESCAPE}|\\#{RE_NEWLINE}/
      RE_IDENT_START = /[a-zA-Z_\P{ASCII}]|#{RE_ESCAPE}/
      RE_IDENT_PART = /(?:[-a-zA-Z0-9_\P{ASCII}]|#{RE_ESCAPE})*/
      RE_IDENT = /(?:-?(?:#{RE_IDENT_START})|--)(?:#{RE_IDENT_PART})*/
      RE_STRING =
        /
          "(?:(?!#{RE_NEWLINE})[^"\\]|#{RE_ESCAPE_NEWLINE})*"
        | '(?:(?!#{RE_NEWLINE})[^'\\]|#{RE_ESCAPE_NEWLINE})*'
        /x
      RE_SUBSTITUTE = /\$#{RE_IDENT}/
      RE_VALUE = /#{RE_IDENT}|#{RE_STRING}|#{RE_SUBSTITUTE}/

      def self.unescape_ident(ident)
        return nil unless ident

        ident.gsub(RE_ESCAPE) do |escape|
          if escape[1] =~ /\H/
            escape[1]
          else
            escape[1..].to_i(16).chr
          end
        end
      end

      def self.unescape_value(value)
        if value[0] == '"' || value[0] == "'"
          value =
            value[1...-1].gsub(RE_ESCAPE_NEWLINE) do |escape|
              if escape[1] =~ /[\n\r\f]/
                ""
              elsif escape[1] =~ /\H/
                escape[1]
              else
                escape[1..].to_i(16).chr
              end
            end
          String[value]
        elsif value[0] == "$"
          Substitution[unescape_ident(value[1..])]
        else
          Ident[unescape_ident(value)]
        end
      end

      def self.unescape_namespace(value)
        return nil unless value

        if value == "*"
          UniversalNamespace[]
        else
          Namespace[name: unescape_ident(value)]
        end
      end

      private

      # See https://www.w3.org/TR/selectors-4/#grammar.
      #
      # ```
      # <selector-list> = <complex-selector-list>
      # <complex-selector-list> = <complex-selector>#
      # <compound-selector-list> = <compound-selector>#
      # <simple-selector-list> = <simple-selector>#
      # <relative-selector-list> = <relative-selector>#
      #
      # <complex-selector> = <compound-selector> [ <combinator>? <compound-selector> ]*
      # <relative-selector> = <combinator>? <complex-selector>
      # <compound-selector> = [ <type-selector>? <subclass-selector>*
      #                         [ <pseudo-element-selector> <pseudo-class-selector>* ]* ]!
      # <simple-selector> = <type-selector> | <subclass-selector>
      #
      # <combinator> = '>' | '+' | '~' | [ '|' '|' ]
      # <type-selector> = <wq-name> | <ns-prefix>? '*'
      # <ns-prefix> = [ <ident-token> | '*' ]? '|'
      # <wq-name> = <ns-prefix>? <ident-token>
      # <subclass-selector> = <id-selector> | <class-selector> |
      #                       <attribute-selector> | <pseudo-class-selector>
      #
      # <id-selector> = <hash-token>
      # <class-selector> = '.' <ident-token>
      # <attribute-selector> = '[' <wq-name> ']' |
      #                        '[' <wq-name> <attr-matcher> [ <string-token> | <ident-token> ] <attr-modifier>? ']'
      # <attr-matcher> = [ '~' | '|' | '^' | '$' | '*' ]? '='
      # <attr-modifier> = i | s
      # <pseudo-class-selector> = ':' <ident-token> |
      #                           ':' <function-token> <any-value> ')'
      # <pseudo-element-selector> = ':' <pseudo-class-selector>
      # ```

      # ```
      # <selector-list> = <complex-selector-list>
      # <complex-selector-list> = <complex-selector>#
      # <relative-selector-list> = <relative-selector>#
      # ```

      def parse_selector_list
        selector_list = parse_complex_selector_list
        @scanner.scan RE_WS
        raise ParseError.new("expected end-of-string", @scanner.charpos) unless @scanner.eos?

        selector_list
      end

      def parse_complex_selector_list
        selectors = parse_comma_separated_list { parse_complex_selector }
        SelectorList[selectors:]
      end

      def parse_relative_selector_list
        selectors = parse_comma_separated_list { parse_relative_selector }
        RelativeSelectorList[selectors:]
      end

      # ```
      # <complex-selector> = <compound-selector> [ <combinator>? <compound-selector> ]*
      # <relative-selector> = <combinator>? <complex-selector>
      #
      # <combinator> = '>' | '+' | '~' | [ '|' '|' ]
      # ```

      def parse_complex_selector
        last = parse_compound_selector
        pairs = []

        while (combinator = try_parse_combinator)
          pairs << [last, combinator]
          last = parse_compound_selector
        end

        pairs.reverse_each { |(prev, combinator)| last = ComplexSelector[left: prev, combinator:, right: last] }
        last
      end

      def parse_relative_selector
        combinator = try_parse_combinator || :descendant
        selector = parse_complex_selector
        RelativeSelector[combinator:, right: selector]
      end

      RE_COMBINATOR = /#{RE_WS}(?:[>+~]|\|\|)#{RE_WS}|(?:#{RE_WHITESPACE})+(?![,)])/

      def try_parse_combinator
        return nil unless @scanner.scan(RE_COMBINATOR)

        case @scanner[0].strip
        when ">"
          return :child
        when "~"
          return :sibling
        when "+"
          return :adjacent
        when "||"
          return :column
        when ""
          return :descendant
        end

        raise "unreachable"
      end

      # ```
      # <compound-selector> = [ <type-selector>? <subclass-selector>*
      #                         [ <pseudo-element-selector> <pseudo-class-selector>* ]* ]!
      # ```

      def parse_compound_selector
        type = try_parse_type_selector

        subclasses = []
        while (subclass = try_parse_subclass_selector)
          subclasses << subclass
        end

        pseudo_elements = []
        while (pseudo_element = try_parse_pseudo_element_selector)
          pseudo_elements << pseudo_element
        end

        if type.nil? && subclasses.empty? && pseudo_elements.empty?
          raise ParseError.new("expected type, subclass, or pseudo element selector", @scanner.charpos)
        end

        CompoundSelector[type:, subclasses:, pseudo_elements:]
      end

      # ```
      # <type-selector> = <wq-name> | <ns-prefix>? '*'
      #
      # <ns-prefix> = [ <ident-token> | '*' ]? '|'
      # <wq-name> = <ns-prefix>? <ident-token>
      # ```

      RE_TYPE_SELECTOR = /(?:(?<namespace>#{RE_IDENT}|\*)\|)?(?<tag_name>#{RE_IDENT}|\*)/

      def try_parse_type_selector
        return nil unless @scanner.scan(RE_TYPE_SELECTOR)

        namespace = Parser.unescape_namespace(@scanner[:namespace])
        tag_name = @scanner[:tag_name]

        return UniversalType[namespace:] if tag_name == "*"

        TagNameType[namespace:, tag_name: Parser.unescape_ident(tag_name)]
      end

      # ```
      # <subclass-selector> = <id-selector> | <class-selector> |
      #                       <attribute-selector> | <pseudo-class-selector>
      #
      # <id-selector> = <hash-token>
      # <class-selector> = '.' <ident-token>
      # <attribute-selector> = '[' <wq-name> ']' |
      #                        '[' <wq-name> <attr-matcher> [ <string-token> | <ident-token> ] <attr-modifier>? ']'
      # <attr-matcher> = [ '~' | '|' | '^' | '$' | '*' ]? '='
      # <attr-modifier> = i | s
      # ```

      RE_SUBCLASS_SELECTOR =
        /
        \#(?<id>#{RE_IDENT})
      | \.(?<class>#{RE_IDENT})
      | \[
          #{RE_WS}
          (?:(?<attr_namespace>#{RE_IDENT}|\*)\|)?
          (?<attr_name>#{RE_IDENT})
          #{RE_WS}
          (?:
            (?<attr_matcher>[~|^$*]?=)
            #{RE_WS}
            (?<attr_value>#{RE_VALUE})
            #{RE_WS}
            (?<attr_modifier>[is])?
            #{RE_WS}
          )?
        \]
      /x

      def try_parse_subclass_selector
        return try_parse_pseudo_class_selector unless @scanner.scan(RE_SUBCLASS_SELECTOR)

        return Id[name: Parser.unescape_ident(@scanner[:id])] if @scanner[:id]

        return ClassName[name: Parser.unescape_ident(@scanner[:class])] if @scanner[:class]

        namespace = Parser.unescape_namespace(@scanner[:attr_namespace])
        name = Parser.unescape_ident(@scanner[:attr_name])

        if @scanner[:attr_matcher]
          matcher = @scanner[:attr_matcher].intern
          value = Parser.unescape_value(@scanner[:attr_value])
          modifier = @scanner[:attr_modifier]&.intern
        else
          matcher = value = modifier = nil
        end

        Attribute[namespace:, name:, matcher:, value:, modifier:]
      end

      # ```
      # <pseudo-class-selector> = ':' <ident-token> |
      #                           ':' <function-token> <any-value> ')'
      # <pseudo-element-selector> = ':' <pseudo-class-selector>
      # ```

      RE_PSEUDO_CLASS_SELECTOR = /:(?<name>#{RE_IDENT})/
      RE_PSEUDO_ELEMENT_SELECTOR = /::(?<name>#{RE_IDENT})/
      RE_OPEN_PAREN = /#{RE_WS}\(#{RE_WS}/
      RE_CLOSE_PAREN = /#{RE_WS}\)/
      RE_OF = /#{RE_WS}of#{RE_WS}/

      def try_parse_pseudo_class_selector
        return nil unless @scanner.scan(RE_PSEUDO_CLASS_SELECTOR)

        name = Parser.unescape_ident(@scanner[:name])

        if @scanner.scan(RE_OPEN_PAREN)
          argument = parse_function_argument(@config[:pseudo_classes][name]&.argument_kind)
        end

        PseudoClass[name:, argument:]
      end

      def try_parse_pseudo_element_selector
        return nil unless @scanner.scan(RE_PSEUDO_ELEMENT_SELECTOR)

        name = Parser.unescape_ident(@scanner[:name])
        argument = parse_function_argument(nil) if @scanner.scan(RE_OPEN_PAREN)

        pseudo_classes = []
        while (pseudo_class = try_parse_pseudo_class_selector)
          pseudo_classes << pseudo_class
        end

        PseudoElement[name:, argument:, pseudo_classes:]
      end

      def parse_function_argument(argument_kind)
        case argument_kind
        when :selector_list
          selector_list = parse_complex_selector_list
          scan! RE_CLOSE_PAREN, '")"'
          selector_list
        when :relative_selector_list
          selector_list = parse_relative_selector_list
          scan! RE_CLOSE_PAREN, '")"'
          selector_list
        when :nth
          nth = parse_nth
          scan! RE_CLOSE_PAREN, '")"'
          nth
        when :nth_of_selector_list
          nth = parse_nth
          selector_list = parse_complex_selector_list if @scanner.scan(RE_OF)
          scan! RE_CLOSE_PAREN, '")"'
          NthOfSelectorList[nth:, selector_list:]
        else
          raise "BUG: unknown pseudo-function kind: #{argument_kind}" if argument_kind

          value_list = parse_value_list
          scan! RE_CLOSE_PAREN, '")"'
          value_list
        end
      end

      RE_NTH = /odd\b|even\b|(?:(?<a>[+-]?\d+|[+-]?)n)?(?<b>(?:(?:[+-]|(?<!n)[+-]?)\d+)?)/

      def parse_nth
        scan! RE_NTH, '"odd", "even", or An+B'
        case @scanner[0]
        when "odd"
          Odd[]
        when "even"
          Even[]
        when ""
          raise ParseError.new('expected "odd", "even", or An+B', @scanner.charpos)
        else
          a =
            case @scanner[:a]
            when "+", ""
              1
            when "-"
              -1
            when nil
              0
            else
              @scanner[:a].to_i
            end
          b =
            case @scanner[:b]
            when ""
              0
            else
              @scanner[:b].to_i
            end
          Nth[a:, b:]
        end
      end

      def parse_value_list
        values = parse_comma_separated_list { parse_value }
        ValueList[values:]
      end

      RE_BARE_VALUE = /[^,)]*/

      def parse_value
        if @scanner.scan RE_VALUE
          Parser.unescape_value @scanner[0]
        else
          @scanner.scan RE_BARE_VALUE
          Bare[value: @scanner[0].strip]
        end
      end

      RE_COMMA = /#{RE_WS},#{RE_WS}/

      def parse_comma_separated_list(&)
        list = []
        list << yield

        list << yield while @scanner.scan(RE_COMMA)

        list
      end

      def scan!(regexp, error_token)
        return if @scanner.scan(regexp)

        raise ParseError.new("expected #{error_token}", @scanner.charpos)
      end

      # :startdoc:
    end
  end
end
