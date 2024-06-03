# frozen_string_literal: true

# Adopted from:
# - <https://github.com/fb55/css-select/blob/master/test/nwmatcher.ts>

require "test_helper"

module REXML
  module CSSSelector
    class TestNWMatcher < Minitest::Test
      include Fixture::Helper

      def setup
        @document = Fixture.load_nwmatcher
      end

      # Basic:

      def test_universal
        elements = []
        @document.each_recursive { |element| elements << element if element.is_a?(::REXML::Element) }

        assert_equal elements, select_all("*")
      end

      def test_element
        elements = []
        @document.each_recursive do |element|
          elements << element if element.is_a?(::REXML::Element) && element.name == "li"
        end

        assert_equal elements, select_all("li")
        assert_equal ids("strong"), select_all("strong", id("fixtures"))
        assert_empty select_all("nonexistent")
      end

      def test_id
        assert_equal ids("fixtures"), select_all("#fixtures")
        assert_empty select_all("#nonexistent")
        assert_equal ids("troubleForm"), select_all("#troubleForm")
      end

      def test_class_name
        assert_equal ids("p", "link_1", "item_1"), select_all(".first")
        assert_empty select_all(".nonexistent")
      end

      def test_element_id
        assert_equal ids("strong"), select_all("strong#strong")
        assert_empty select_all("p#nonexistent")
      end

      def test_element_class_name
        assert_equal ids("link_1", "link_2"), select_all("a.internal")
        assert_equal ids("link_2"), select_all("a.internal.highlight")
        assert_equal ids("link_2"), select_all("a.highlight.internal")
        assert_empty select_all("a.internal.nonexistent")
      end

      def test_id_class_name
        assert_equal ids("link_2"), select_all("#link_2.internal")
        assert_equal ids("link_2"), select_all(".internal#link_2")
        assert_equal ids("link_2"), select_all("#link_2.internal.highlight")
        assert_empty select_all("#link_2.internal.nonexistent")
      end

      def test_element_id_class_name
        assert_equal ids("link_2"), select_all("a#link_2.internal")
        assert_equal ids("link_2"), select_all("a.internal#link_2")
        assert_equal ids("item_1"), select_all("li#item_1.first")
        assert_empty select_all("li#item_1.nonexistent")
        assert_empty select_all("li#item_1.first.nonexistent")
      end

      # Attribute:

      def test_attribute
        assert_equal select_all("a[href]"), select_all("[href]", select("body"))
        assert_equal select_all("a[class~=internal]"), select_all("[class~=internal]")
        assert_equal select_all("*[id]"), select_all("[id]")
        assert_equal ids("checked_radio", "unchecked_radio"), select_all("[type=radio]")
        assert_equal select_all("*[type=checkbox]"), select_all("[type=checkbox]")
        assert_equal ids("with_title", "commaParent"), select_all("[title]")
        assert_equal select_all("#troubleForm *[type=radio]"), select_all("#troubleForm [type=radio]")
        assert_equal select_all("#troubleForm *[type]"), select_all("#troubleForm [type]")
      end

      def test_element_attribute
        assert_equal select_all("#fixtures h1"), select_all("h1[class]")
        assert_equal select_all("#fixtures h1"), select_all("h1[CLASS]", html: true)
        assert_equal ids("item_3"), select_all("li#item_3[class]")
        assert_equal ids("chk_1", "chk_2"), select_all('#troubleForm2 input[name="brackets[5][]"]')
        assert_equal ids("chk_1"), select_all('#troubleForm2 input[name="brackets[5][]"]:checked')
        assert_equal ids("with_title"), select_all('cite[title="hello world!"]')
      end

      def test_namespace_attribute
        assert_equal select_all(":root, #item_3"), select_all("[xml|lang]")
        assert_equal select_all(":root, #item_3"), select_all("*[xml|lang]")
      end

      def test_element_attribute_equal_value
        assert_equal ids("link_1", "link_2", "link_3"), select_all('a[href="#"]')
        assert_equal ids("chk_2"), select_all('#troubleForm2 input[name="brackets[5][]"][value="2"]')
      end

      def test_element_attribute_tilda_equal_value
        assert_equal ids("link_1", "link_2"), select_all('a[class~="internal"]')
        assert_equal ids("link_1", "link_2"), select_all("a[class~=internal]")
        assert_equal ids("link_3"), select_all('a[class~="external"][href="#"]')
      end

      def test_element_attribute_bar_equal_value
        assert_equal ids("item_3"), select_all('*[xml|lang|="es"]')
        assert_equal ids("item_3"), select_all('*[xml|lang|="ES"]', html: true)
      end

      def test_element_attribute_start_with_value
        assert_equal ids("father", "uncle"), select_all("div[class^=bro]")
        assert_equal ids("level2_1", "level2_2", "level2_3"), select_all('#level1 *[id^="level2_"]')
        assert_equal ids("level2_1", "level2_2", "level2_3"), select_all("#level1 *[id^=level2_]")
      end

      def test_element_attribute_end_with_value
        assert_equal ids("father", "uncle"), select_all('div[class*="ers m"]')
        assert_equal ids("level2_1", "level3_2", "level2_2", "level2_3"), select_all('#level1 *[id*="2"]')
      end

      # Pseudo class:

      def test_first_child
        assert_equal ids("level2_1"), select_all("#level1>*:first-child")
        assert_equal ids("level2_1", "level3_1", "level_only_child"), select_all("#level1 *:first-child")
        assert_empty select_all("#level1>div:first-child")
        assert_equal ids("level2_1", "level3_1"), select_all("#level1 span:first-child")
        assert_empty select_all("#level1:first-child")
      end

      def test_last_child
        assert_equal ids("level2_3"), select_all("#level1>*:last-child")
        assert_equal ids("level3_2", "level_only_child", "level2_3"), select_all("#level1 *:last-child")
        assert_equal ids("level2_3"), select_all("#level1>div:last-child")
        assert_equal ids("level2_3"), select_all("#level1 div:last-child")
        assert_empty select_all("#level1>span:last-child")
      end

      def test_nth_child
        assert_equal ids("link_2"), select_all("#p *:nth-child(3)")
        assert_equal ids("link_2"), select_all("#p a:nth-child(3)")
        assert_equal ids("item_2", "item_3"), select_all("#list > li:nth-child(n+2)")
        assert_equal ids("item_1", "item_2"), select_all("#list > li:nth-child(-n+2)")
      end

      def test_nth_of_type
        assert_equal ids("link_1"), select_all("#p a:nth-of-type(1)")
        assert_equal ids("link_2"), select_all("#p a:nth-of-type(2)")
      end

      def test_nth_last_of_type
        assert_equal ids("link_2"), select_all("#p a:nth-last-of-type(1)")
        assert_equal ids("link_1"), select_all("#p a:nth-last-of-type(2)")
      end

      def test_first_of_type
        assert_equal ids("link_1"), select_all("#p a:first-of-type")
      end

      def test_last_of_type
        assert_equal ids("link_2"), select_all("#p a:last-of-type")
      end

      def test_only_child
        assert_equal ids("level_only_child"), select_all("#level1 *:only-child")
        assert_empty select_all("#level1>*:only-child")
        assert_empty select_all("#level1:only-child")
        assert_empty select_all("#level2_2 :only-child:not(:first-child)")
        assert_empty select_all("#level2_2 :only-child:not(:last-child)")
      end

      def test_empty
        assert_equal ids("level3_1"), select_all("#level3_1:empty")
        assert_empty select_all("span:empty > *")
      end

      def test_not
        assert_empty select_all('a:not([href="#"])')
        assert_empty select_all("div.brothers:not(.brothers)")
        assert_empty select_all('a[class~=external]:not([href="#"])')
        assert_equal ids("link_2"), select_all("#p a:not(:first-of-type)")
        assert_equal ids("link_1"), select_all("#p a:not(:last-of-type)")
        assert_equal ids("link_2"), select_all("#p a:not(:nth-of-type(1))")
        assert_equal ids("link_1"), select_all("#p a:not(:nth-last-of-type(1))")
        assert_equal ids("link_2"), select_all("#p a:not([rel~=nofollow])")
        assert_equal ids("link_2"), select_all("#p a:not([rel^=external])")
        assert_equal ids("link_2"), select_all("#p a:not([rel$=nofollow])")
        assert_equal ids("em"), select_all('#p a:not([rel$="nofollow"]) > em')
        assert_equal ids("em"), select_all('#p a:not([rel$="nofollow"]) em')
        assert_equal ids("item_2"), select_all("#list li:not(#item_1):not(#item_3)")
        assert_equal ids("son"), select_all("#grandfather > div:not(#uncle) #son")
      end

      def test_disabled
        assert_equal ids("disabled_text_field"), select_all("#troubleForm > p > *:disabled")
      end

      def test_checked
        assert_equal ids("checked_box", "checked_radio"), select_all("#troubleForm *:checked")
      end

      # Combinator:

      def test_descendant
        assert_equal ids("em2", "em", "span"), select_all("#fixtures a *")
        assert_equal ids("p"), select_all("div#fixtures p#p")
      end

      def test_adjacent
        assert_equal ids("uncle"), select_all("div.brothers + div.brothers")
        assert_equal ids("uncle"), select_all("div.brothers + div")

        assert_equal ids("level2_2"), select_all("#level2_1+span")
        assert_equal ids("level2_2"), select_all("#level2_1 + span")
        assert_equal ids("level2_2"), select_all("#level2_1 + *")
        assert_empty select_all("#level2_2 + span")
        assert_equal ids("level3_2"), select_all("#level3_1 + span")
        assert_equal ids("level3_2"), select_all("#level3_1 + *")
        assert_empty select_all("#level3_1 + em")
        assert_empty select_all("#level3_2 + span")
      end

      def test_child
        assert_equal ids("link_1", "link_2"), select_all("p.first > a")
        assert_equal ids("father", "uncle"), select_all("div#grandfather > div")
        assert_equal ids("level2_1", "level2_2"), select_all("#level1>span")
        assert_equal ids("level2_1", "level2_2"), select_all("#level1 > span")
        assert_equal ids("level3_1", "level3_2"), select_all("#level2_1 > *")
        assert_empty select_all("div > #nonexistent")
      end

      def test_sibling
        assert_equal ids("list"), select_all("h1 ~ ul")
        assert_empty select_all("#level2_2 ~ span")
        assert_empty select_all("#level3_2 ~ *")
        assert_empty select_all("#level3_1 ~ em")
        assert_empty select_all("div ~ #level3_2")
        assert_empty select_all("div ~ #level2_3")
        assert_equal ids("level2_2"), select_all("#level2_1 ~ span")
        assert_equal ids("level2_2", "level2_3"), select_all("#level2_1 ~ *")
        assert_equal ids("level3_2"), select_all("#level3_1 ~ #level3_2")
        assert_equal ids("level3_2"), select_all("span ~ #level3_2")
      end

      # Other:

      def test_is_function
        element = id("dupL1")

        assert CSSSelector.is(element, "span")
        assert CSSSelector.is(element, "span#dupL1")
        assert CSSSelector.is(element, "div > span")
        assert CSSSelector.is(element, "#dupContainer span")
        assert CSSSelector.is(element, "#dupL1")
        assert CSSSelector.is(element, "span.span_foo")
        assert CSSSelector.is(element, "span.span_bar")
        assert CSSSelector.is(element, "span:first-child")

        refute CSSSelector.is(element, "span.span_wtf")
        refute CSSSelector.is(element, "#dupL2")
        refute CSSSelector.is(element, "div")
        refute CSSSelector.is(element, "span span")
        refute CSSSelector.is(element, "span > span")
        refute CSSSelector.is(element, "span:nth-child(5)")
        refute CSSSelector.is(element, "span:nth-child(5)")

        assert CSSSelector.is(id("link_1"), "a[rel^=external]")
        refute CSSSelector.is(id("link_2"), "a[rel^=external]")
      end

      def test_equivalent_selector
        assert_equal select_all("div[class~=brothers]"), select_all("div.brothers")
        assert_equal select_all("div[class~=brothers].brothers"), select_all("div.brothers")
        assert_equal select_all("div:not([class~=brothers])"), select_all("div:not(.brothers)")
        assert_equal select_all("li:not(:first-child)"), select_all("li ~ li")
        assert_equal select_all("ul > li:nth-child(n)"), select_all("ul > li")
        assert_equal select_all("ul > li:nth-child(2n)"), select_all("ul > li:nth-child(even)")
        assert_equal select_all("ul > li:nth-child(2n+1)"), select_all("ul > li:nth-child(odd)")
        assert_equal select_all("ul > li:nth-child(1)"), select_all("ul > li:first-child")
        assert_equal select_all("ul > li:nth-last-child(1)"), select_all("ul > li:last-child")
        assert_equal select_all("ul > li"), select_all("ul > li:nth-child(n-128)")
        assert_equal select_all('#p a:not([rel$="nofollow"]) > em'), select_all('#p a:not([rel$="nofollow"])>em')
      end

      def test_multiple_selectors
        assert_equal ids("commaParent", "commaChild"),
                     select_all('form[title*="commas,"], input[value="#commaOne,#commaTwo"]')
      end

      def test_multiple_selectors_with_lang
        assert_equal ids("p", "link_1", "list", "item_1", "item_3", "troubleForm"),
                     select_all('#list, .first,*[xml|lang="es-us"] , #troubleForm')
      end
    end
  end
end
