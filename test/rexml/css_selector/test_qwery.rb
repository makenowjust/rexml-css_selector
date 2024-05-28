# frozen_string_literal: true

# Adopted from:
# - <https://github.com/ded/qwery/blob/master/tests/tests.js>
# - <https://github.com/fb55/css-select/blob/master/test/qwery.ts>

require "test_helper"

module REXML
  module CSSSelector
    class TestQwery < Minitest::Test
      include Fixture::Helper

      def setup
        @document = Fixture.load_qwery
        @small_document = REXML::Document.new(<<~HTML)
          <root>
            <div id="hsoob">
              <div class="a b">
                <div class="d e sib" test="fg" id="booshTest">
                  <p><span id="spanny"></span></p>
                </div>
                <em nopass="copyrighters" rel="copyright booshrs" test="f g" class="sib"></em>
                <span class="h i a sib"></span>
              </div>
              <p class="odd"></p>
            </div>
            <div id="lonelyHsoob"></div>
          </root>
          HTML
        @fragment = REXML::Document.new(<<~HTML).root
          <root>
            <div class="d i v">
              <p id="oooo"><em></em><em id="emem"></em></p>
            </div>
            <p id="sep">
              <div class="a"><span></span></div>
            </p>
          </root>
          HTML
      end

      # Small document:

      def test_small_document_get_element_by_id
        assert_equal 1, select_all("#hsoob", @small_document).size
      end

      def test_small_document_get_elements_by_class
        assert_equal 2, select_all("#hsoob .a", @small_document).size
        assert_equal 1, select_all("#hsoob div.a", @small_document).size
        assert_equal 2, select_all("#hsoob div", @small_document).size
        assert_equal 2, select_all("#hsoob span", @small_document).size
        assert_equal 1, select_all("#hsoob div div", @small_document).size
        assert_equal 1, select_all("p.odd", @small_document).size
      end

      def test_small_document_complex_selectors
        assert_equal 2, select_all(".d ~ .sib", @small_document).size
        assert_equal 1, select_all(".a .d + .sib", @small_document).size
        assert_equal 1, select_all("#hsoob > div > .h", @small_document).size
        assert_equal 1, select_all('.a .d ~ .sib[test="f g"]', @small_document).size
      end

      def test_small_by_id_subqueries
        assert_equal 1, select_all("#hsoob #spanny", @small_document).size
        assert_equal 1, select_all(".a #spanny", @small_document).size
        assert_equal 1, select_all(".a #booshTest #spanny", @small_document).size
        assert_equal 1, select_all(":root > #hsoob", @small_document).size
      end

      def test_small_document_by_id_subqueries_within_subcontext
        assert_equal 1, select_all("#spanny", select("#hsoob", @small_document)).size
        assert_equal 1, select_all(".a #spanny", select("#hsoob", @small_document)).size
        assert_equal 1, select_all(".a #booshTest #spanny", select("#hsoob", @small_document)).size
        assert_equal 1, select_all(".a > #booshTest", select("#hsoob", @small_document)).size
        assert_equal 0, select_all("#booshTest", select("#spanny", @small_document)).size
        assert_equal 0, select_all("#booshTest", select("#lonelyHsoob", @small_document)).size
      end

      # CSS 1:

      def test_css1_get_element_by_id
        assert_equal 1, select_all("#boosh").size
      end

      def test_css1_by_id_subqueries
        assert_equal 1, select_all("#boosh #booshTest").size
        assert_equal 1, select_all(".a.b #booshTest").size
        assert_equal 1, select_all("#boosh>.a>#booshTest").size
        assert_equal 1, select_all(".a>#booshTest").size
      end

      def test_css1_get_elements_by_class
        assert_equal 2, select_all("#boosh .a").size
        assert_equal 1, select_all("#boosh div.a").size
        assert_equal 2, select_all("#boosh div").size
        assert_equal 1, select_all("#boosh span").size
        assert_equal 1, select_all("a.odd").size
      end

      def test_css1_combos
        assert_equal 3, select_all("#boosh div, #boosh span").size
      end

      def test_css1_class_with_dashes
        assert_equal 1, select_all(".class-with-dashes").size
      end

      def test_css1_should_ignore_comment_nodes
        assert_equal 4, select_all("#boosh *").size
      end

      def test_css1_deep_messy_relationships
        assert_equal 5, select_all("div#fixtures > div a").size
        assert_equal 1, select_all(".direct-descend > .direct-descend .lvl2").size
        assert_equal 1, select_all(".direct-descend > .direct-descend div").size
        assert_equal 0, select_all("div#fixtures div ~ a div").size
        assert_equal 0, select_all(".direct-descend > .direct-descend > .direct-descend ~ .lvl2").size
      end

      # CSS 2:

      def test_css2_get_elements_by_attribute
        assert_equal 1, select_all("#boosh div[test=fg]").size
        assert_equal 1, select_all('em[rel~="copyright"]').size
        assert_equal 0, select_all('em[nopass~="copyright"]').size
      end

      def test_css2_should_not_throw_error_by_attribute_selector
        assert_equal 1, select_all('[foo^="bar"]').size
      end

      def test_css2_crazy_town
        assert_equal 1, select_all('div#attr-test3.found.you[title="whatup duders"]').size
      end

      # CSS 3:

      def test_css3_direct_descendants
        assert_equal 2, select_all("#direct-descend > .direct-descend").size
        assert_equal 3, select_all("#direct-descend > .direct-descend > .lvl2").size
      end

      def test_css3_sibling_elements
        assert_equal 2, select_all("#sibling-selector ~ .sibling-selector").size
        assert_equal 2, select_all("#sibling-selector ~ div.sibling-selector").size
        assert_equal 1, select_all("#sibling-selector + .sibling-selector").size
        assert_equal 1, select_all("#sibling-selector + div.sibling-selector").size

        assert_equal 4, select_all(".parent .oldest ~ .sibling").size
        assert_equal 2, select_all(".parent .middle ~ .sibling").size
        assert_equal 1, select_all(".parent .middle ~ h4").size
        assert_equal 1, select_all(".parent .middle ~ h4.younger").size
        assert_equal 0, select_all(".parent .middle ~ h3").size
        assert_equal 0, select_all(".parent .middle ~ h2").size
        assert_equal 0, select_all(".parent .youngest ~ .sibling").size

        assert_equal 1, select_all(".parent .oldest + .sibling").size
        assert_equal 1, select_all(".parent .middle + .sibling").size
        assert_equal 1, select_all(".parent .middle + h4").size
        assert_equal 0, select_all(".parent .middle + h3").size
        assert_equal 0, select_all(".parent .middle + h2").size
        assert_equal 0, select_all(".parent .youngest + .sibling").size
      end

      # Attribute:

      def test_attribute_attr
        assert_equal 1, select_all("#attributes div[unique-test]").size
      end

      def test_attribute_attr_equal
        assert_equal 1, select_all('#attributes div[test="two-foo"]').size
        assert_equal 1, select_all("#attributes div[test='two-foo']").size
        assert_equal 1, select_all("#attributes div[test=two-foo]").size
      end

      def test_attribute_attr_tilda_equal
        assert_equal 1, select_all('#attributes div[test~="three"]').size
      end

      def test_attribute_attr_bar_equal
        assert_equal 1, select_all('#attributes div[test|="two-foo"]').size
        assert_equal 1, select_all('#attributes div[test|="two"]').size
      end

      def test_attribute_attr_equal_hash
        assert_equal 1, select_all('#attributes a[href="#aname"]').size
      end

      def test_attribute_start_with
        assert_equal 1, select_all("#attributes div[test^=two]").size
      end

      def test_attribute_end_with
        assert_equal 1, select_all("#attributes div[test$=foo]").size
      end

      def test_attribute_include
        assert_equal 1, select_all("#attributes div[test*=hree]").size
      end

      # Scope:

      def test_scope_scoped_queries
        assert_equal 2, select_all(":scope > .direct-descend", select("#direct-descend")).size
        assert_equal 1, select_all(":scope > .tokens a", select(".idless")).size
      end

      def test_scope_detached_fragments
        assert_equal 1, select_all(".a span", @fragment).size
        assert_equal 2, select_all(":scope > div p em", @fragment).size
      end

      def test_scope_by_id_subqueries_within_detached_fragment
        assert_equal 1, select_all("#emem", @fragment).size
        assert_equal 1, select_all(".d.i #emem", @fragment).size
        assert_equal 1, select_all(".d #oooo #emem", @fragment).size
        assert_equal 1, select_all(":scope > div #oooo", @fragment).size
        assert_equal 0, select_all("#oooo", select("#emem", @fragment)).size
        assert_equal 0, select_all("#sep", select("#emem", @fragment)).size
      end

      def test_scope_exclude_self_in_match
        assert_equal 4, select_all(".order-matters", select("#order-matters")).size
      end

      def test_scope_forms_can_be_used_as_contexts
        assert_equal 3, select_all("*", select("form")).size
      end

      # Parse:

      def test_parse_should_not_get_weird_tokens
        assert_equal [select("#token-one")], select_all('div .tokens[title="one"]')
        assert_equal [select("#token-two")], select_all('div .tokens[title="one two"]')
        assert_equal [select("#token-three")], select_all('div .tokens[title="one two three #%"]')
        assert_equal [select("#token-four")], select_all('div .tokens[title="one two three #%"] a')
        assert_equal [select("#token-five")], select_all('div .tokens[title="one two three #%"] a[href$=foo] div')
      end

      def test_parse_should_parse_bad_selectors
        assert_equal 1, select_all("#spaced-tokens    p    em    a").size
      end

      # Order:

      def test_order_of_elements_return_matters
        elements = select_all("#order-matters .order-matters")

        assert_equal %w[p a em b], elements.map(&:name)
      end

      # Pseudo class:

      def test_pseudo_class_not
        assert_equal 1, select_all(".odd:not(div)").size
      end

      def test_pseudo_class_first_child
        assert_equal [select_all("#pseudos > *").first], select_all("#pseudos div:first-child")
      end

      def test_pseudo_class_last_child
        assert_equal [select_all("#pseudos > div").last], select_all("#pseudos div:last-child")
      end

      def test_pseudo_class_last_child_complex
        assert_equal [select("#attr-child-boosh")], select_all('ol > li[attr="boosh"]:last-child')
      end

      def test_pseudo_class_only_child
        assert_equal [select("#token-four"), select("#token-five")], select_all("#token-three :only-child")
        assert_equal 0, select_all("#idless > :only-child").size
      end

      def test_pseudo_class_nth_child_simple
        assert_equal 4, select_all("#pseudos :nth-child(odd)").size
        assert_equal 3, select_all("#pseudos div:nth-child(odd)").size
        assert_equal 3, select_all("#pseudos div:nth-child(even)").size
        assert_equal [select_all("#pseudos > div")[1]], select_all("#pseudos div:nth-child(2)")
      end

      def test_pseudo_class_nth_child_complex
        assert_equal 3, select_all("#pseudos :nth-child(3n+1)").size
        assert_equal 3, select_all("#pseudos :nth-child(3n-2)").size
        assert_equal 6, select_all("#pseudos :nth-child(-n+6)").size
        assert_equal 5, select_all("#pseudos :nth-child(-n+5)").size

        children = select_all("#pseudos > *")
        get = ->(*indices) { indices.map { children[_1 - 1] } }

        assert_equal get.call(2, 5), select_all("#pseudos :nth-child(3n+2)")
        assert_equal get.call(3, 6), select_all("#pseudos :nth-child(3n)")
      end

      def test_pseudo_class_nth_last_child_simple
        assert_equal 4, select_all("#pseudos :nth-last-child(odd)").size
        assert_equal 3, select_all("#pseudos div:nth-last-child(odd)").size
        assert_equal 3, select_all("#pseudos div:nth-last-child(even)").size
        assert_equal [select_all("#pseudos > div")[1]], select_all("#pseudos div:nth-last-child(6)")
      end

      def test_pseudo_class_nth_last_child_complex
        assert_equal 3, select_all("#pseudos :nth-last-child(3n+1)").size
        assert_equal 3, select_all("#pseudos :nth-last-child(3n-2)").size
        assert_equal 6, select_all("#pseudos :nth-last-child(-n+6)").size
        assert_equal 5, select_all("#pseudos :nth-last-child(-n+5)").size

        children = select_all("#pseudos > *")
        get = ->(*indices) { indices.map { children[_1 - 1] } }

        assert_equal get.call(3, 6), select_all("#pseudos :nth-last-child(3n+2)")
        assert_equal get.call(2, 5), select_all("#pseudos :nth-last-child(3n)")
      end

      def test_pseudo_class_first_of_type
        assert_equal [select_all("#pseudos > div").first], select_all("#pseudos div:first-of-type")
      end

      def test_pseudo_class_last_of_type
        assert_equal [select_all("#pseudos > div").last], select_all("#pseudos div:last-of-type")
      end

      def test_pseudo_class_only_of_child
        assert_equal [select("#pseudos a")], select_all("#pseudos :only-of-type")
        assert_equal [select("#pseudos a")], select_all("#pseudos a:only-of-type")
        assert_equal 0, select_all("#pseudos div:only-of-type").size
      end

      def test_pseudo_class_nth_of_type
        assert_equal 2, select_all("#pseudos div:nth-of-type(3n+1)").size
        assert_equal 1, select_all("#pseudos a:nth-of-type(3n+1)").size
        assert_equal 0, select_all("#pseudos a:nth-of-type(3n)").size
        assert_equal 1, select_all("#pseudos a:nth-of-type(odd)").size
        assert_equal 1, select_all("#pseudos a:nth-of-type(1)").size
      end

      def test_pseudo_class_nth_last_of_type
        assert_equal 2, select_all("#pseudos div:nth-last-of-type(3n+1)").size
        assert_equal 1, select_all("#pseudos a:nth-last-of-type(3n+1)").size
        assert_equal 0, select_all("#pseudos a:nth-last-of-type(3n)").size
        assert_equal 1, select_all("#pseudos a:nth-last-of-type(odd)").size
        assert_equal 1, select_all("#pseudos div:nth-last-of-type(5)").size
      end
    end
  end
end
