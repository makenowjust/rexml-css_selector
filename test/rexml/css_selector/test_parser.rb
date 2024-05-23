# frozen_string_literal: true

require "test_helper"

module REXML
  class CSSSelector
    class TestParser < Minitest::Test
      def assert_parse(source, expected)
        parser = Parser.new(source)
        actual = parser.parse

        assert_equal expected, actual
      end

      def assert_parse_compound(source, type: nil, subclasses: [], pseudo_elements: [])
        parser = Parser.new(source)
        actual = parser.parse

        assert_equal SelectorList[selectors: [CompoundSelector[type:, subclasses:, pseudo_elements:]]], actual
      end

      def test_parse_tag_name_type_selector
        assert_parse_compound "a", type: TagNameType[namespace: nil, tag_name: "a"]
        assert_parse_compound "abc", type: TagNameType[namespace: nil, tag_name: "abc"]
        assert_parse_compound 'a\>\a b', type: TagNameType[namespace: nil, tag_name: "a>\nb"]
        assert_parse_compound "*|a", type: TagNameType[namespace: UniversalNamespace[], tag_name: "a"]
        assert_parse_compound "a|a", type: TagNameType[namespace: Namespace[name: "a"], tag_name: "a"]
      end

      def test_parse_universal_type_selector
        assert_parse_compound "*", type: UniversalType[namespace: nil]
        assert_parse_compound "*|*", type: UniversalType[namespace: UniversalNamespace[]]
        assert_parse_compound "a|*", type: UniversalType[namespace: Namespace[name: "a"]]
        assert_parse_compound "abc|*", type: UniversalType[namespace: Namespace[name: "abc"]]
        assert_parse_compound 'a\>\a b|*', type: UniversalType[namespace: Namespace[name: "a>\nb"]]
      end

      def test_parse_id_selector
        assert_parse_compound "#a", subclasses: [Id[name: "a"]]
        assert_parse_compound "#abc", subclasses: [Id[name: "abc"]]
        assert_parse_compound '#a\>\a b', subclasses: [Id[name: "a>\nb"]]
      end

      def test_parse_class_name_selector
        assert_parse_compound ".a", subclasses: [ClassName[name: "a"]]
        assert_parse_compound ".abc", subclasses: [ClassName[name: "abc"]]
        assert_parse_compound '.a\>\a b', subclasses: [ClassName[name: "a>\nb"]]
      end

      def test_parse_attribute_selector
        assert_parse_compound "[a]",
                              subclasses: [
                                Attribute[namespace: nil, name: "a", matcher: nil, value: nil, modifier: nil]
                              ]
        assert_parse_compound "[*|a]",
                              subclasses: [
                                Attribute[
                                  namespace: UniversalNamespace[],
                                  name: "a",
                                  matcher: nil,
                                  value: nil,
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound "[a=b]",
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"=",
                                  value: Ident[value: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound "[a~=b]",
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"~=",
                                  value: Ident[value: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound "[a|=b]",
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"|=",
                                  value: Ident[value: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound "[a^=b]",
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"^=",
                                  value: Ident[value: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound "[a$=b]",
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"$=",
                                  value: Ident[value: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound "[a*=b]",
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"*=",
                                  value: Ident[value: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound '[a="b"]',
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"=",
                                  value: String[value: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound "[a='b']",
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"=",
                                  value: String[value: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound "[a=$b]",
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"=",
                                  value: Substitution[name: "b"],
                                  modifier: nil
                                ]
                              ]
        assert_parse_compound '[a="b"i]',
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"=",
                                  value: String[value: "b"],
                                  modifier: :i
                                ]
                              ]
        assert_parse_compound '[a="b"s]',
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"=",
                                  value: String[value: "b"],
                                  modifier: :s
                                ]
                              ]
        assert_parse_compound '[ a = "b" i ]',
                              subclasses: [
                                Attribute[
                                  namespace: nil,
                                  name: "a",
                                  matcher: :"=",
                                  value: String[value: "b"],
                                  modifier: :i
                                ]
                              ]
      end

      def test_parse_pseudo_class_selector
        assert_parse_compound ":a", subclasses: [PseudoClass[name: "a", argument: nil]]
        assert_parse_compound ":abc", subclasses: [PseudoClass[name: "abc", argument: nil]]
        assert_parse_compound ':a\>\a b', subclasses: [PseudoClass[name: "a>\nb", argument: nil]]
        assert_parse_compound ':a(abc, 123, "foo", $bar)',
                              subclasses: [
                                PseudoClass[
                                  name: "a",
                                  argument:
                                    ValueList[
                                      values: [
                                        Ident[value: "abc"],
                                        Bare[value: "123"],
                                        String[value: "foo"],
                                        Substitution[name: "bar"]
                                      ]
                                    ]
                                ]
                              ]
      end

      def test_parse_pseudo_class_nth_argument
        assert_parse_compound ":nth-of-type(even)", subclasses: [PseudoClass[name: "nth-of-type", argument: Even[]]]
        assert_parse_compound ":nth-last-of-type(even)",
                              subclasses: [PseudoClass[name: "nth-last-of-type", argument: Even[]]]
        assert_parse_compound ":nth-of-type(odd)", subclasses: [PseudoClass[name: "nth-of-type", argument: Odd[]]]
        assert_parse_compound ":nth-of-type(1)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: 0, b: 1]]]
        assert_parse_compound ":nth-of-type(-1)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: 0, b: -1]]]
        assert_parse_compound ":nth-of-type(n)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: 1, b: 0]]]
        assert_parse_compound ":nth-of-type(+n)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: 1, b: 0]]]
        assert_parse_compound ":nth-of-type(-n)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: -1, b: 0]]]
        assert_parse_compound ":nth-of-type(n+1)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: 1, b: 1]]]
        assert_parse_compound ":nth-of-type(-n+1)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: -1, b: 1]]]
        assert_parse_compound ":nth-of-type(12n+1)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: 12, b: 1]]]
        assert_parse_compound ":nth-of-type(+12n+1)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: 12, b: 1]]]
        assert_parse_compound ":nth-of-type(-12n+1)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: -12, b: 1]]]
        assert_parse_compound ":nth-of-type(12n-34)",
                              subclasses: [PseudoClass[name: "nth-of-type", argument: Nth[a: 12, b: -34]]]
      end

      def test_parse_pseudo_class_nth_of_argument
        assert_parse_compound ":nth-child(even)",
                              subclasses: [
                                PseudoClass[
                                  name: "nth-child",
                                  argument: NthOfSelectorList[nth: Even[], selector_list: nil]
                                ]
                              ]
        assert_parse_compound ":nth-last-child(even)",
                              subclasses: [
                                PseudoClass[
                                  name: "nth-last-child",
                                  argument: NthOfSelectorList[nth: Even[], selector_list: nil]
                                ]
                              ]
        assert_parse_compound ":nth-child(odd of a)",
                              subclasses: [
                                PseudoClass[
                                  name: "nth-child",
                                  argument:
                                    NthOfSelectorList[
                                      nth: Odd[],
                                      selector_list:
                                        SelectorList[
                                          selectors: [
                                            CompoundSelector[
                                              type: TagNameType[namespace: nil, tag_name: "a"],
                                              subclasses: [],
                                              pseudo_elements: []
                                            ]
                                          ]
                                        ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":nth-child(odd of a, b)",
                              subclasses: [
                                PseudoClass[
                                  name: "nth-child",
                                  argument:
                                    NthOfSelectorList[
                                      nth: Odd[],
                                      selector_list:
                                        SelectorList[
                                          selectors: [
                                            CompoundSelector[
                                              type: TagNameType[namespace: nil, tag_name: "a"],
                                              subclasses: [],
                                              pseudo_elements: []
                                            ],
                                            CompoundSelector[
                                              type: TagNameType[namespace: nil, tag_name: "b"],
                                              subclasses: [],
                                              pseudo_elements: []
                                            ]
                                          ]
                                        ]
                                    ]
                                ]
                              ]
      end

      def parse_pseudo_class_selector_list_argument
        assert_parse_compound ":is(.foo)",
                              subclasses: [
                                PseudoClass[
                                  name: "is",
                                  argument:
                                    SelectorList[
                                      selectors: [
                                        CompoundSelector[
                                          type: nil,
                                          subclasses: [ClassName[name: "foo"]],
                                          pseudo_elements: []
                                        ]
                                      ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":is(.foo, :bar)",
                              subclasses: [
                                PseudoClass[
                                  name: "is",
                                  argument:
                                    SelectorList[
                                      selectors: [
                                        CompoundSelector[
                                          type: nil,
                                          subclasses: [ClassName[name: "foo"]],
                                          pseudo_elements: []
                                        ],
                                        CompoundSelector[
                                          type: nil,
                                          subclasses: [ClassName[name: "bar"]],
                                          pseudo_elements: []
                                        ]
                                      ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":where(.foo)",
                              subclasses: [
                                PseudoClass[
                                  name: "where",
                                  argument:
                                    SelectorList[
                                      selectors: [
                                        CompoundSelector[
                                          type: nil,
                                          subclasses: [ClassName[name: "foo"]],
                                          pseudo_elements: []
                                        ]
                                      ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":not(.foo)",
                              subclasses: [
                                PseudoClass[
                                  name: "not",
                                  argument:
                                    SelectorList[
                                      selectors: [
                                        CompoundSelector[
                                          type: nil,
                                          subclasses: [ClassName[name: "foo"]],
                                          pseudo_elements: []
                                        ]
                                      ]
                                    ]
                                ]
                              ]
      end
      def parse_pseudo_class_relative_selector_list_argument
        assert_parse_compound ":has(.foo)",
                              subclasses: [
                                PseudoClass[
                                  name: "is",
                                  argument:
                                    RelativeSelectorList[
                                      selectors: [
                                        RelativeSelector[
                                          combinator: :descendant,
                                          right:
                                            CompoundSelector[
                                              type: nil,
                                              subclasses: [ClassName[name: "foo"]],
                                              pseudo_elements: []
                                            ]
                                        ]
                                      ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":has(.foo, :bar)",
                              subclasses: [
                                PseudoClass[
                                  name: "is",
                                  argument:
                                    RelativeSelectorList[
                                      selectors: [
                                        RelativeSelector[
                                          combinator: :descendant,
                                          right:
                                            CompoundSelector[
                                              type: nil,
                                              subclasses: [ClassName[name: "foo"]],
                                              pseudo_elements: []
                                            ]
                                        ],
                                        RelativeSelector[
                                          combinator: :descendant,
                                          right:
                                            CompoundSelector[
                                              type: nil,
                                              subclasses: [ClassName[name: "bar"]],
                                              pseudo_elements: []
                                            ]
                                        ]
                                      ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":has(> .foo)",
                              subclasses: [
                                PseudoClass[
                                  name: "is",
                                  argument:
                                    RelativeSelectorList[
                                      selectors: [
                                        RelativeSelector[
                                          combinator: :child,
                                          right:
                                            CompoundSelector[
                                              type: nil,
                                              subclasses: [ClassName[name: "foo"]],
                                              pseudo_elements: []
                                            ]
                                        ]
                                      ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":has(+ .foo)",
                              subclasses: [
                                PseudoClass[
                                  name: "is",
                                  argument:
                                    RelativeSelectorList[
                                      selectors: [
                                        RelativeSelector[
                                          combinator: :adjacent,
                                          right:
                                            CompoundSelector[
                                              type: nil,
                                              subclasses: [ClassName[name: "foo"]],
                                              pseudo_elements: []
                                            ]
                                        ]
                                      ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":has(~ .foo)",
                              subclasses: [
                                PseudoClass[
                                  name: "is",
                                  argument:
                                    RelativeSelectorList[
                                      selectors: [
                                        RelativeSelector[
                                          combinator: :sibling,
                                          right:
                                            CompoundSelector[
                                              type: nil,
                                              subclasses: [ClassName[name: "foo"]],
                                              pseudo_elements: []
                                            ]
                                        ]
                                      ]
                                    ]
                                ]
                              ]
        assert_parse_compound ":has(|| .foo)",
                              subclasses: [
                                PseudoClass[
                                  name: "is",
                                  argument:
                                    RelativeSelectorList[
                                      selectors: [
                                        RelativeSelector[
                                          combinator: :column,
                                          right:
                                            CompoundSelector[
                                              type: nil,
                                              subclasses: [ClassName[name: "foo"]],
                                              pseudo_elements: []
                                            ]
                                        ]
                                      ]
                                    ]
                                ]
                              ]
      end

      def test_parse_pseudo_element_selector
        assert_parse_compound "::before",
                              pseudo_elements: [PseudoElement[name: "before", argument: nil, pseudo_classes: []]]
        assert_parse_compound "::foo:bar",
                              pseudo_elements: [
                                PseudoElement[
                                  name: "foo",
                                  argument: nil,
                                  pseudo_classes: [PseudoClass[name: "bar", argument: nil]]
                                ]
                              ]
      end

      def test_parse_compound_selector
        assert_parse_compound "foo.bar#baz[hoge=fuga]:fizz(buzz)::fizzbuzz",
                              type: TagNameType[namespace: nil, tag_name: "foo"],
                              subclasses: [
                                ClassName[name: "bar"],
                                Id[name: "baz"],
                                Attribute[
                                  namespace: nil,
                                  name: "hoge",
                                  matcher: :"=",
                                  value: Ident[value: "fuga"],
                                  modifier: nil
                                ],
                                PseudoClass[name: "fizz", argument: ValueList[values: [Ident[value: "buzz"]]]]
                              ],
                              pseudo_elements: [PseudoElement[name: "fizzbuzz", argument: nil, pseudo_classes: []]]
      end

      def test_parse_complex_selector
        assert_parse "foo bar",
                     SelectorList[
                       selectors: [
                         ComplexSelector[
                           left:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "foo"],
                               subclasses: [],
                               pseudo_elements: []
                             ],
                           combinator: :descendant,
                           right:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "bar"],
                               subclasses: [],
                               pseudo_elements: []
                             ]
                         ]
                       ]
                     ]
        assert_parse "foo bar baz",
                     SelectorList[
                       selectors: [
                         ComplexSelector[
                           left:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "foo"],
                               subclasses: [],
                               pseudo_elements: []
                             ],
                           combinator: :descendant,
                           right:
                             ComplexSelector[
                               left:
                                 CompoundSelector[
                                   type: TagNameType[namespace: nil, tag_name: "bar"],
                                   subclasses: [],
                                   pseudo_elements: []
                                 ],
                               combinator: :descendant,
                               right:
                                 CompoundSelector[
                                   type: TagNameType[namespace: nil, tag_name: "baz"],
                                   subclasses: [],
                                   pseudo_elements: []
                                 ]
                             ]
                         ]
                       ]
                     ]
        assert_parse "foo > bar",
                     SelectorList[
                       selectors: [
                         ComplexSelector[
                           left:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "foo"],
                               subclasses: [],
                               pseudo_elements: []
                             ],
                           combinator: :child,
                           right:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "bar"],
                               subclasses: [],
                               pseudo_elements: []
                             ]
                         ]
                       ]
                     ]
        assert_parse "foo + bar",
                     SelectorList[
                       selectors: [
                         ComplexSelector[
                           left:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "foo"],
                               subclasses: [],
                               pseudo_elements: []
                             ],
                           combinator: :adjacent,
                           right:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "bar"],
                               subclasses: [],
                               pseudo_elements: []
                             ]
                         ]
                       ]
                     ]
        assert_parse "foo ~ bar",
                     SelectorList[
                       selectors: [
                         ComplexSelector[
                           left:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "foo"],
                               subclasses: [],
                               pseudo_elements: []
                             ],
                           combinator: :sibling,
                           right:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "bar"],
                               subclasses: [],
                               pseudo_elements: []
                             ]
                         ]
                       ]
                     ]
        assert_parse "foo || bar",
                     SelectorList[
                       selectors: [
                         ComplexSelector[
                           left:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "foo"],
                               subclasses: [],
                               pseudo_elements: []
                             ],
                           combinator: :column,
                           right:
                             CompoundSelector[
                               type: TagNameType[namespace: nil, tag_name: "bar"],
                               subclasses: [],
                               pseudo_elements: []
                             ]
                         ]
                       ]
                     ]
      end

      def test_parse_selector_list
        assert_parse "foo, bar",
                     SelectorList[
                       selectors: [
                         CompoundSelector[
                           type: TagNameType[namespace: nil, tag_name: "foo"],
                           subclasses: [],
                           pseudo_elements: []
                         ],
                         CompoundSelector[
                           type: TagNameType[namespace: nil, tag_name: "bar"],
                           subclasses: [],
                           pseudo_elements: []
                         ]
                       ]
                     ]
      end
    end
  end
end
