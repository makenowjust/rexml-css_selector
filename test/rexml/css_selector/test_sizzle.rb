# frozen_string_literal: true

# Adopted from:
# - <https://github.com/fb55/css-select/blob/master/test/sizzle.ts>

require "test_helper"

module REXML
  module CSSSelector
    class TestSizzle < Minitest::Test
      include Fixture::Helper

      def setup
        @document = Fixture.load_sizzle
        @xml_document = Fixture.load_sizzle_xml
      end

      def assert_select(selector, ids, scope = @document, **config)
        assert_equal ids(*ids), select_all(selector, scope, **config)
      end

      def assert_broken(selector)
        assert_raises(ParseError, CompileError) { select_all(selector) }
      end

      def test_element_universal
        assert_empty select_all("div", ::REXML::Text.new(""))
        assert_operator select_all("*").size, :>=, 30
        assert select_all("*").all? { _1.node_type == :element }
      end

      def test_element_simple
        assert_select "html", %w[html]
        assert_select "body", %w[body]
        assert_select "#qunit-fixture p", %w[firstp ap sndp en sap first]
      end

      def test_element_leading_space
        assert_select " #qunit-fixture p", %w[firstp ap sndp en sap first]
        assert_select "\t#qunit-fixture p", %w[firstp ap sndp en sap first]
        assert_select "\r#qunit-fixture p", %w[firstp ap sndp en sap first]
        assert_select "\n#qunit-fixture p", %w[firstp ap sndp en sap first]
        assert_select "\f#qunit-fixture p", %w[firstp ap sndp en sap first]
      end

      def test_element_trailing_space
        assert_select "#qunit-fixture p ", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p\t", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p\r", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p\n", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p\f", %w[firstp ap sndp en sap first]
      end

      def test_element_child
        assert_select "dl ol", %w[empty listWithTabIndex]
        assert_select "dl\tol", %w[empty listWithTabIndex]
      end

      def test_element_object
        assert_equal 2, select_all("param", id("object1")).size
      end

      def test_element_form
        assert_select "select", %w[select1 select2 select3 select4 select5], id("form")
      end

      def test_element_order
        assert_equal select_all("p"), select_all("p, div p")
        assert_select "h2, h1", %w[qunit-header qunit-banner qunit-userAgent]
        assert_select "#qunit-fixture p, #qunit-fixture p a",
                      %w[firstp simon1 ap google groups anchor1 mark sndp en yahoo sap anchor2 simon first]
      end

      def test_element_id
        assert_select "#idTest", %w[idTest], id("lengthtest")
        assert_select "[name='id']", %w[idTest], id("lengthtest")
        assert_select "input[id='idTest']", %w[idTest], id("lengthtest")
      end

      def test_element_sibling
        siblings = %w[siblingfirst siblingnext siblingthird siblingchild siblinggrandchild siblinggreatgrandchild]

        assert_select "div em", siblings, id("siblingTest")
        assert_select "div em, em\\,", siblings, id("siblingTest")
      end

      def test_element_iframe
        iframe = id("iframe")
        iframe_body = ::REXML::Document.new(<<~HTML).root
          <body><p id='foo'>bar</p></body>
          HTML
        iframe << iframe_body

        assert_equal select_all("#foo", iframe), select_all("p", iframe)
      end

      def test_element_deep_nesting
        divs = ""
        100.times { divs = "<div>#{divs}</div>" }
        element = ::REXML::Document.new(divs).root
        body = id("body")
        body << element

        assert_equal 112, select_all("body div div div").size
        assert_equal 98, select_all("body>div div div").size
      end

      def test_element_tostring
        # NOTE: This test seems JavaScript specific, so that it is unnecessary for this library.

        element = ::REXML::Element.new("toString")
        element.add_attribute("id", "toString")
        fixture = id("qunit-fixture")
        fixture << element

        assert_equal ids("toString"), select_all("toString#toString")
        assert_equal ids("toString"), select_all("tostring#toString", html: true)
      end

      def text_xml_document
        assert_equal 1, select_all("foo_bar", @xml_document)
        assert_equal 1, select_all(".component", @xml_document)
        assert_equal 1, select_all("[class*=component]", @xml_document)
        assert_equal 1, select_all("property[name=prop2]", @xml_document)
        assert_equal 1, select_all("[name=prop2]", @xml_document)
        assert_equal 1, select_all("#seite1", @xml_document)
        assert_equal 1, select_all("component", @xml_document).filter { is(_1, "#seite1") }.size
        assert_equal 2, select_all("meta property thing").size
        assert is(@xml_document.root, "soap|Envelope")

        small_xml_document = ::REXML::Document.new(<<~XML)
          <?xml version='1.0' encoding='UTF-8'?><root><elem id='1'/></root>
          XML

        assert_equal 1, select_all("elem:not(:has(*))", small_xml_document).size
      end

      def test_broken
        assert_broken "["
        assert_broken "("
        assert_broken "{"
        assert_broken "()"
        assert_broken "<>"
        assert_broken "{}"
        assert_broken ","
        assert_broken ",a"
        assert_broken "a,"
        assert_broken "[id=012345678901234567890123456789"
        assert_broken ":visble"
        assert_broken ":nth-child"
        assert_broken ":nth-child(-)"
        assert_broken ":nth-child(asdf)"
        assert_broken ":nth-child(2n+-0)"
        assert_broken ":nth-child(2+0)"
        assert_broken ":nth-child(- 1n)"
        assert_broken ":nth-child(-1 n)"
        assert_broken ":first-child(n)"
        assert_broken ":last-child(n)"
        assert_broken ":only-child(n)"
        assert_broken ":nth-last-last-child(1)"
        assert_broken ":first-last-child"
        assert_broken ":last-last-child"
        assert_broken ":only-last-child"
        assert_broken "input[name=foo[baz]]"
      end

      def test_id
        assert_select "body#body", %w[body]
        assert_select "ul#first", []
        assert_select "#firstp #simon1", %w[simon1]
        assert_select "#firstp #foobar", []
        assert_select "#台北Táiběi", %w[台北Táiběi]
        assert_select "#台北Táiběi, #台北", %w[台北Táiběi 台北]
        assert_select "div #台北", %w[台北]
        assert_select "form > #台北", %w[台北]

        assert_select "#foo\\:bar", %w[foo:bar]
        assert_select "#test\\.foo\\[5\\]bar", %w[test.foo[5]bar]
        assert_select "div #foo\\:bar", %w[foo:bar]
        assert_select "div #test\\.foo\\[5\\]bar", %w[test.foo[5]bar]
        assert_select "form > #foo\\:bar", %w[foo:bar]
        assert_select "form > #test\\.foo\\[5\\]bar", %w[test.foo[5]bar]

        # TODO: Currently, `:input` pseudo-class is not supproted.
        # Note that `:input` is a non-standard pseudo-class introduced by jQuery.
        # See https://api.jquery.com/input-selector/.
        # assert_select "#foo\\:bar span:not(:input)", %w[foo_descendent]
      end

      def test_id_fiddle
        element = ::REXML::Document.new(<<~XML).root
          <div id='fiddle\\Foo'><span id='fiddleSpan'></span></div>
          XML
        fixture = id("qunit-fixture")
        fixture << element

        assert_select ":scope > span", %w[fiddleSpan], select("#fiddle\\\\Foo")
      end

      def test_id_parent
        assert_select "#form > #radio1", %w[radio1]
        assert_select "#form #first", []
        assert_select "#form > #option1a", []
        assert_select "#foo > *", %w[sndp en sap]
        assert_select "#firstUL > *", []
      end

      def test_id_value
        assert_equal "tName1", select("#tName1")["id"]
        assert_select "#tName2", []
        assert_select "#tName2 span", []
        assert_select "#tName1 span", %w[tName1-span]
        assert_equal "tName1", select("div > div #tName1")["id"]
        assert_equal "tName1", select("#tName1-span").parent["id"]
      end

      def test_id_backslash
        element = ::REXML::Document.new(<<~XML).root
          <a id='backslash\\foo'></a>
          XML
        form = id("form")
        form << element

        assert_select "#backslash\\\\foo", %w[backslash\\foo]
      end

      def test_id_misc
        assert_select "#lengthtest", %w[lengthtest]
        assert_select "#asdfasdf #foobar", []
        assert_select "div#form", []
        assert_select "#types_all", %w[types_all]
        assert_select "#qunit-fixture", %w[qunit-fixture]
        assert_select "#name\\+value", %w[name+value]
      end

      def test_class
        assert_select ".blog", %w[mark simon]
        assert_select ".GROUPS", %w[groups]
        assert_select ".blog.link", %w[simon]
        assert_select "a.blog", %w[mark simon]
        assert_select "p .blog", %w[mark simon]
        assert_select ".台北Táiběi", %w[utf8class1]
        assert_select ".台北", %w[utf8class1 utf8class2]
        assert_select ".台北Táiběi.台北", %w[utf8class1]
        assert_select ".台北Táiběi, .台北", %w[utf8class1 utf8class2]
        assert_select "div .台北Táiběi", %w[utf8class1]
        assert_select "form > .台北Táiběi", %w[utf8class1]
        assert_select ".foo\\:bar", %w[foo:bar]
        assert_select ".test\\.foo\\[5\\]bar", %w[test.foo[5]bar]
        assert_select "div .foo\\:bar", %w[foo:bar]
        assert_select "div .test\\.foo\\[5\\]bar", %w[test.foo[5]bar]
        assert_select "form > .foo\\:bar", %w[foo:bar]
        assert_select "form > .test\\.foo\\[5\\]bar", %w[test.foo[5]bar]
      end

      def test_class_div
        div = ::REXML::Element.new("div")
        div << ::REXML::Document.new("<div class='test e'></div>").root
        div << ::REXML::Document.new("<div class='test'></div>").root

        assert_equal [div.children[0]], select_all(".e", div)

        div.children[1].attributes["class"] = "e"

        assert_equal [div.children[0], div.children[1]], select_all(".e", div)

        refute CSSSelector.is(div, ".null")
        refute CSSSelector.is(div.children[0], ".null div")

        div.attributes["class"] = "null"

        assert CSSSelector.is(div, ".null")
        assert CSSSelector.is(div.children[0], ".null div")

        div.children[1].attributes["class"] += " hasOwnProperty toString"

        assert_equal [div.children[1]], select_all(".e.hasOwnProperty.toString", div)
      end

      def test_class_svg
        div = ::REXML::Document.new(<<~XML).root
          <div>
            <svg width='200' height='250' version='1.1' xmlns='http://www.w3.org/2000/svg'>
              <rect x='10' y='10' width='30' height='30' class='foo'></rect>
            </svg>
          </div>
          XML
        assert_equal 1, select_all(".foo", div).size
      end

      def test_name
        assert_select "input[name=action]", %w[text1]
        assert_select "input[name='action']", %w[text1]
        assert_select 'input[name="action"]', %w[text1]
        assert_select "[name=example]", %w[name-is-example]
        assert_select "[name=div]", %w[name-is-div]
        assert_select "*[name=iframe]", %w[iframe]
        assert_select "input[name='types[]']", %w[types_all types_anime types_movie]
      end

      def test_name_form
        form = id("form")

        assert_select "input[name=action]", %w[text1], form
        assert_select "input[name='foo[bar]']", %w[hidden2], form
      end

      def test_name_new_form
        form = ::REXML::Document.new("<form><input name='id'/></form>").root
        body = id("body")
        body << form

        assert_equal 1, select_all("input", form).size
      end

      def test_name_simple
        assert_select "[name=tName1]", %w[tName1ID]
        assert_select "[name=tName2]", %w[tName2ID]
        assert_select "#tName2ID", %w[tName2ID]
      end

      def test_multiple
        assert_select "h2, #qunit-fixture p", %w[qunit-banner qunit-userAgent firstp ap sndp en sap first]
        assert_select "h2 , #qunit-fixture p", %w[qunit-banner qunit-userAgent firstp ap sndp en sap first]
        assert_select "h2 , #qunit-fixture p", %w[qunit-banner qunit-userAgent firstp ap sndp en sap first]
        assert_select "h2,#qunit-fixture p", %w[qunit-banner qunit-userAgent firstp ap sndp en sap first]
        assert_select "h2,#qunit-fixture p ", %w[qunit-banner qunit-userAgent firstp ap sndp en sap first]
        assert_select "h2\t,\r#qunit-fixture p\n", %w[qunit-banner qunit-userAgent firstp ap sndp en sap first]
      end

      def test_child_and_adjacent
        assert_select "p > a", %w[simon1 google groups mark yahoo simon]
        assert_select "p> a", %w[simon1 google groups mark yahoo simon]
        assert_select "p >a", %w[simon1 google groups mark yahoo simon]
        assert_select "p>a", %w[simon1 google groups mark yahoo simon]
        assert_select "p > a.blog", %w[mark simon]
        assert_select "code > *", %w[anchor1 anchor2]
        assert_select "p > * > *", %w[anchor1 anchor2]
        assert_select "#qunit-fixture a + a", %w[groups tName2ID]
        assert_select "#qunit-fixture a +a", %w[groups tName2ID]
        assert_select "#qunit-fixture a+ a", %w[groups tName2ID]
        assert_select "#qunit-fixture a+a", %w[groups tName2ID]
        assert_select "p + p", %w[ap en sap]
        assert_select "p#firstp + p", %w[ap]
        assert_select "p[lang=en] + p", %w[sap]
        assert_select "a.GROUPS + code + a", %w[mark]
        assert_select "#qunit-fixture a + a, code > a", %w[groups anchor1 anchor2 tName2ID]
        assert_select "#qunit-fixture p ~ div",
                      %w[foo nothiddendiv moretests tabindex-tests liveHandlerOrder siblingTest]
        assert_select "#first ~ div", %w[moretests tabindex-tests liveHandlerOrder siblingTest]
        assert_select "#groups ~ a", %w[mark]
        assert_select "#length ~ input", %w[idTest]
        assert_select "#siblingfirst ~ em", %w[siblingnext siblingthird]
        assert_select "#siblingTest em ~ em ~ em ~ span", %w[siblingspan]

        # TODO: Currently, `:contains` pseudo-class is not supported.
        # assert_select("#liveHandlerOrder ~ div em:contains('1')", ["siblingfirst"]);
      end

      def test_child_and_adjacent_complex
        assert_select "#siblingTest em *", %w[siblingchild siblinggrandchild siblinggreatgrandchild]
        assert_select "#siblingTest > em *", %w[siblingchild siblinggrandchild siblinggreatgrandchild]
        assert_select "#siblingTest > em:first-child + em ~ span", %w[siblingspan]

        # TODO: Currently, `:contains` pseudo-class is not supported.
        # assert_select "#siblingTest > em:contains('x') + em ~ span", []

        assert_equal 1, select_all("#listWithTabIndex").size
        assert_empty select_all("#__sizzle__")
        assert_equal 1, select_all("#listWithTabIndex").size

        assert_select "div.blah > p > a", []
        assert_select "div.foo > span > a", []
        assert_select ".fototab > .thumbnails > a", []
        assert_select ":scope > label", ["scopeTest--child"], id("scopeTest")
      end

      def test_attribute
        assert_select "#qunit-fixture a[title]", %w[google]
        assert_select "#qunit-fixture a[TITLE]", %w[google], html: true
        assert_select "#qunit-fixture *[title]", %w[google]
        assert_select "#qunit-fixture [title]", %w[google]
        assert_select "#qunit-fixture a[ title ]", %w[google]

        assert_select "#select2 option[selected]", %w[option2d]
        assert_select "#select2 option[selected='selected']", %w[option2d]

        assert_select "#qunit-fixture a[rel='bookmark']", %w[simon1]
        assert_select "#qunit-fixture a[rel='bookmark']", %w[simon1]
        assert_select "#qunit-fixture a[rel=bookmark]", %w[simon1]
        assert_select "#qunit-fixture a[href='http://www.google.com/']", %w[google]
        assert_select "#qunit-fixture a[ rel = 'bookmark' ]", %w[simon1]
        assert_select "#qunit-fixture option[value='1']", %w[option1b option2b option3b option4b option5c]
        assert_select "#qunit-fixture li[tabIndex='-1']", %w[foodWithNegativeTabIndex], html: true
      end

      def test_attribute_anchor
        id("anchor2").attributes["href"] = "#2"

        assert_select "p a[href^='#']", %w[anchor2]
        assert_select "p a[href*='#']", %w[simon1 anchor2]
      end

      def test_attribute_for
        assert_select "form label[for]", %w[label-for]
        assert_select "#form [for=action]", %w[label-for]
      end

      def test_attribute_bracket
        assert_select "input[name^='foo[']", %w[hidden2]
        assert_select "input[name^='foo[bar]']", %w[hidden2]
        assert_select "input[name*='[bar]']", %w[hidden2]
        assert_select "input[name$='bar]']", %w[hidden2]
        assert_select "input[name$='[bar]']", %w[hidden2]
        assert_select "input[name$='foo[bar]']", %w[hidden2]
        assert_select "input[name*='foo[bar]']", %w[hidden2]
      end

      def test_attribute_comma
        assert_select "input[data-comma='0,1']", %w[el12087]
        assert_select 'input[data-comma="0,1"]', %w[el12087]
        assert_select "input[data-comma='0,1']", %w[el12087], id("t12087")
        assert_select 'input[data-comma="0,1"]', %w[el12087], id("t12087")
      end

      def test_attribute_form
        assert_select "#form input[type='radio'], #form input[type='hidden']", %w[radio1 radio2 hidden1]
        assert_select "#form input[type='radio'], #form input[type=\"hidden\"]", %w[radio1 radio2 hidden1]
        assert_select "#form input[type='radio'], #form input[type=hidden]", %w[radio1 radio2 hidden1]
      end

      def test_attribute_utf8
        assert_select "span[lang=中文]", %w[台北]
      end

      def test_attribute_value_match
        assert_select "a[href ^= 'http://www']", %w[google yahoo]
        assert_select "a[href $= 'org/']", %w[mark]
        assert_select "a[href *= 'google']", %w[google groups]

        # TODO: `!=` matcher is not supported because it is jQuery extension.
        # See https://api.jquery.com/attribute-not-equal-selector.
        # assert_select "#ap a[hreflang!='en']", %w[google groups anchor1]
      end

      def test_attribute_option
        opt = id("option1a")
        opt.attributes["test"] = ""

        assert CSSSelector.is(opt, "[id*=option1]")
        assert CSSSelector.is(opt, "[test='']")
        refute CSSSelector.is(opt, "[test^='']")
        assert CSSSelector.is(opt, "[id=option1a]")
        assert CSSSelector.is(id("simon1"), "a[href*='#']")

        assert_select "#select1 option[value='']", %w[option1a]

        # TODO: `!=` matcher is not supported because it is a jQuery extension.
        # See https://api.jquery.com/attribute-not-equal-selector/.
        # assert CSSSelector.is(opt, "[id*=option1][type!=checkbox]")
        # assert_select "#select1 option[value!='']", %w[option1b option1c option1d]

        # TODO: `:selected` is not supported because it is a jQuery extension.
        # See https://api.jquery.com/selected-selector/.
        # assert_select "#select1 option:selected", %w[option1a]
        # assert_select "#select2 option:selected", %w[option2d];
        # assert_select "#select3 option:selected", %w[option3b option3c]
        # assert_select "select[name='select2'] option:selected", %w[option2d]
      end

      def test_attribute_input
        assert_select "input[name='foo[bar]']", %w[hidden2]

        input = id("text1")
        input.attributes["title"] = "Don't click me"

        assert CSSSelector.is(input, 'input[title="Don\'t click me"]')

        input.attributes["data-pos"] = ":first"

        assert CSSSelector.is(input, "input[data-pos=\\:first]")
        assert CSSSelector.is(input, "input[data-pos=':first']")

        # TODO: Currently, `:input` pseudo-class is not supproted.
        # Note that `:input` is a non-standard pseudo-class introduced by jQuery.
        # See https://api.jquery.com/input-selector/.
        # assert CSSSelector.is(input, ":input[data-pos=':first']")
      end

      def test_attribute_input_complex
        inputs = <<~HTML.lines.map { ::REXML::Document.new(_1).root }
          <input type='hidden' id='attrbad_space' name='foo bar'/>
          <input type='hidden' id='attrbad_dot' value='2' name='foo.baz'/>
          <input type='hidden' id='attrbad_brackets' value='2' name='foo[baz]'/>
          <input type='hidden' id='attrbad_injection' data-attr='foo_baz&#39;]'/>
          <input type='hidden' id='attrbad_quote' data-attr='&#39;'/>
          <input type='hidden' id='attrbad_backslash' data-attr='&#92;'/>
          <input type='hidden' id='attrbad_backslash_quote' data-attr='&#92;&#39;'/>
          <input type='hidden' id='attrbad_backslash_backslash' data-attr='&#92;&#92;'/>
          <input type='hidden' id='attrbad_unicode' data-attr='&#x4e00;'/>
          HTML
        fixture = id("qunit-fixture")
        inputs.each { fixture << _1 }

        assert_select "input[id=types_all]", %w[types_all]
        assert_select "input[name=foo\\ bar]", %w[attrbad_space]
        assert_select "input[name=foo\\.baz]", %w[attrbad_dot]
        assert_select "input[name=foo\\[baz\\]]", %w[attrbad_brackets]
        assert_select "input[data-attr='foo_baz\\']']", %w[attrbad_injection]
        assert_select "input[data-attr='\\'']", %w[attrbad_quote]
        assert_select "input[data-attr='\\\\']", %w[attrbad_backslash]
        assert_select "input[data-attr='\\\\\\'']", %w[attrbad_backslash_quote]
        assert_select "input[data-attr='\\\\\\\\']", %w[attrbad_backslash_backslash]
        assert_select "input[data-attr='\\5C\\\\']", %w[attrbad_backslash_backslash]
        assert_select "input[data-attr='\\5C \\\\']", %w[attrbad_backslash_backslash]
        assert_select "input[data-attr='\\5C\t\\\\']", %w[attrbad_backslash_backslash]
        assert_select "input[data-attr='\\04e00']", %w[attrbad_unicode]

        id("attrbad_unicode").attributes["data-attr"] = "\u{01D306}A"

        assert_select "input[data-attr='\\01D306A']", %w[attrbad_unicode]
      end

      def test_attribute_misc
        assert_select "#form input[type=text]", %w[text1 text2 hidden2 name]
        assert_select "#form input[type=search]", %w[search]
        assert_select "#moretests script[src]", %w[script-src]
      end

      def test_attribute_namespace
        div = ::REXML::Element.new("div")
        div << ::REXML::Document.new("<div id='foo' xml:test='something'></div>").root

        assert_equal [div.children[0]], select_all("[xml|test]", div)
      end

      def test_attribute_foo
        # NOTE: This test seems JavaScript specific, so that it is unnecessary for this library.

        foo = id("foo")

        assert_select "[constructor]", []
        assert_select "[watch]", []

        foo.attributes["constructor"] = "foo"
        foo.attributes["watch"] = "bar"

        assert_select "[constructor='foo']", %w[foo]
        assert_select "[watch='bar']", %w[foo]

        assert_select "input[value=Test]", %w[text1 text2]
      end

      def test_pseudo_empty
        assert_select "ul:empty", %w[firstUL]
        assert_select "ol:empty", %w[empty]

        # TODO: `:parent` is not supported because it is a jQuery extension.
        # See https://api.jquery.com/parent-selector/.
        # assert_select "#qunit-fixture p:parent", %w[firstp ap sndp en sap first]
      end

      def test_pseudo_first_child
        assert_select "p:first-child", %w[firstp sndp]
        assert_select "#qunit-fixture p:first-child", %w[firstp sndp]
        assert_select ".nothiddendiv div:first-child", %w[nothiddendivchild]
        assert_select "#qunit-fixture p:FIRST-CHILD", %w[firstp sndp]
      end

      def test_pseudo_last_child
        assert_select "p:last-child", %w[sap]
        assert_select "#qunit-fixture a:last-child", %w[simon1 anchor1 mark yahoo anchor2 simon liveLink1 liveLink2]
      end

      def test_pseudo_only_child
        assert_select "#qunit-fixture a:only-child", %w[simon1 anchor1 yahoo anchor2 liveLink1 liveLink2]
      end

      def test_pseudo_of_type
        assert_select "#qunit-fixture > p:first-of-type", %w[firstp]
        assert_select "#qunit-fixture > p:last-of-type", %w[first]
        assert_select "#qunit-fixture > :only-of-type", %w[name+value firstUL empty floatTest iframe table]
      end

      def test_pseudo_second_child
        second_children = select_all("p:nth-child(2)")
        new_nodes =
          second_children.map do |child|
            new_node = ::REXML::Element.new("div")
            child.parent.insert_before(child, new_node)
            new_node
          end

        assert_select "p:nth-child(2)", []

        new_nodes.each { |new_node| new_node.parent.delete(new_node) }

        assert_select "p:nth-child(2)", %w[ap en]
      end

      def test_pseudo_nth_child
        assert_select "p:nth-child(1)", %w[firstp sndp]
        assert_select "p:nth-child( 1 )", %w[firstp sndp]
        assert_select "#select1 option:NTH-child(3)", %w[option1c]
        assert_select "#qunit-fixture p:not(:nth-child(1))", %w[ap en sap first]

        assert_select "#qunit-fixture form#form > *:nth-child(2)", %w[text1]
        assert_select "#qunit-fixture form#form > :nth-child(2)", %w[text1]

        assert_select "#select1 option:nth-child(-1)", []
        assert_select "#select1 option:nth-child(3)", %w[option1c]

        assert_select "#select1 option:nth-child(0n+3)", %w[option1c]

        assert_select "#select1 option:nth-child(1n+0)", %w[option1a option1b option1c option1d]
        assert_select "#select1 option:nth-child(1n)", %w[option1a option1b option1c option1d]
        assert_select "#select1 option:nth-child(n)", %w[option1a option1b option1c option1d]
        assert_select "#select1 option:nth-child(even)", %w[option1b option1d]
        assert_select "#select1 option:nth-child(odd)", %w[option1a option1c]
        assert_select "#select1 option:nth-child(2n)", %w[option1b option1d]
        assert_select "#select1 option:nth-child(2n+1)", %w[option1a option1c]
        assert_select "#select1 option:nth-child(2n + 1)", %w[option1a option1c]
        assert_select "#select1 option:nth-child(+2n + 1)", %w[option1a option1c]
        assert_select "#select1 option:nth-child(3n)", %w[option1c]
        assert_select "#select1 option:nth-child(3n+1)", %w[option1a option1d]
        assert_select "#select1 option:nth-child(3n+2)", %w[option1b]
        assert_select "#select1 option:nth-child(3n+3)", %w[option1c]
        assert_select "#select1 option:nth-child(3n-1)", %w[option1b]
        assert_select "#select1 option:nth-child(3n-2)", %w[option1a option1d]
        assert_select "#select1 option:nth-child(3n-3)", %w[option1c]
        assert_select "#select1 option:nth-child(3n+0)", %w[option1c]
        assert_select "#select1 option:nth-child(-1n+3)", %w[option1a option1b option1c]
        assert_select "#select1 option:nth-child(-n+3)", %w[option1a option1b option1c]
        assert_select "#select1 option:nth-child(-1n + 3)", %w[option1a option1b option1c]
      end

      def test_pseudo_nth_last_child
        assert_select "form:nth-last-child(5)", %w[testForm]
        assert_select "form:nth-last-child( 5 )", %w[testForm]
        assert_select "#select1 option:NTH-last-child(3)", %w[option1b]
        assert_select "#qunit-fixture p:not(:nth-last-child(1))", %w[firstp ap sndp en first]

        assert_select "#select1 option:nth-last-child(-1)", []
        assert_select "#select1 :nth-last-child(3)", %w[option1b]
        assert_select "#select1 *:nth-last-child(3)", %w[option1b]
        assert_select "#select1 option:nth-last-child(3)", %w[option1b]

        assert_select "#select1 option:nth-last-child(0n+3)", %w[option1b]

        assert_select "#select1 option:nth-last-child(1n+0)", %w[option1a option1b option1c option1d]
        assert_select "#select1 option:nth-last-child(1n)", %w[option1a option1b option1c option1d]
        assert_select "#select1 option:nth-last-child(n)", %w[option1a option1b option1c option1d]
        assert_select "#select1 option:nth-last-child(even)", %w[option1a option1c]
        assert_select "#select1 option:nth-last-child(odd)", %w[option1b option1d]
        assert_select "#select1 option:nth-last-child(2n)", %w[option1a option1c]
        assert_select "#select1 option:nth-last-child(2n+1)", %w[option1b option1d]
        assert_select "#select1 option:nth-last-child(2n + 1)", %w[option1b option1d]
        assert_select "#select1 option:nth-last-child(+2n + 1)", %w[option1b option1d]
        assert_select "#select1 option:nth-last-child(3n)", %w[option1b]
        assert_select "#select1 option:nth-last-child(3n+1)", %w[option1a option1d]
        assert_select "#select1 option:nth-last-child(3n+2)", %w[option1c]
        assert_select "#select1 option:nth-last-child(3n+3)", %w[option1b]
        assert_select "#select1 option:nth-last-child(3n-1)", %w[option1c]
        assert_select "#select1 option:nth-last-child(3n-2)", %w[option1a option1d]
        assert_select "#select1 option:nth-last-child(3n-3)", %w[option1b]
        assert_select "#select1 option:nth-last-child(3n+0)", %w[option1b]
        assert_select "#select1 option:nth-last-child(-1n+3)", %w[option1b option1c option1d]
        assert_select "#select1 option:nth-last-child(-n+3)", %w[option1b option1c option1d]
        assert_select "#select1 option:nth-last-child(-1n + 3)", %w[option1b option1c option1d]
      end

      def test_pseudo_nth_of_type
        assert_select ":nth-of-type(-1)", []
        assert_select "#ap :nth-of-type(3)", %w[mark]
        assert_select "#ap :nth-of-type(n)", %w[google groups code1 anchor1 mark]
        assert_select "#ap :nth-of-type(0n+3)", %w[mark]
        assert_select "#ap :nth-of-type(2n)", %w[groups]
        assert_select "#ap :nth-of-type(even)", %w[groups]
        assert_select "#ap :nth-of-type(2n+1)", %w[google code1 anchor1 mark]
        assert_select "#ap :nth-of-type(odd)", %w[google code1 anchor1 mark]
        assert_select "#qunit-fixture > :nth-of-type(-n+2)",
                      %w[firstp ap foo nothiddendiv name+value firstUL empty form floatTest iframe lengthtest table]
      end

      def test_pseudo_nth_last_of_type
        assert_select ":nth-last-of-type(-1)", []
        assert_select "#ap :nth-last-of-type(3)", %w[google]
        assert_select "#ap :nth-last-of-type(n)", %w[google groups code1 anchor1 mark]
        assert_select "#ap :nth-last-of-type(0n+3)", %w[google]
        assert_select "#ap :nth-last-of-type(2n)", %w[groups]
        assert_select "#ap :nth-last-of-type(even)", %w[groups]
        assert_select "#ap :nth-last-of-type(2n+1)", %w[google code1 anchor1 mark]
        assert_select "#ap :nth-last-of-type(odd)", %w[google code1 anchor1 mark]
        assert_select "#qunit-fixture > :nth-last-of-type(-n+2)",
                      %w[
                        ap
                        name+value
                        first
                        firstUL
                        empty
                        floatTest
                        iframe
                        table
                        name-tests
                        testForm
                        liveHandlerOrder
                        siblingTest
                      ]
      end

      def test_pseudo_has
        assert_select "p:has(a)", %w[firstp ap en sap]
        assert_select "p:has( a )", %w[firstp ap en sap]
        assert_select "#qunit-fixture div:has(div:has(div:not([id])))", %w[moretests t2037]
      end

      def test_pseudo_misc
        # TODO: `:header` is not supported because it is a jQuery extension.
        # See https://api.jquery.com/header-selector/.
        # assert_select ":header", %w[qunit-header qunit-banner qunit-userAgent]
        # assert_select ":Header", %w[qunit-header qunit-banner qunit-userAgent]

        # TODO: Currently, `:contains` pseudo-class is not supported.
        # assert_select "#form select:has(option:first-child:contains('o'))", %w[select1 select2 select3 select4]

        refute_empty select_all("#qunit-fixture :not(:has(:has(*)))")

        select = id("select1")

        assert CSSSelector.is(select, ":has(option)")

        # TODO: Currently, `:contains` pseudo-class is not supported.
        # refute_empty select_all("a:contains('')")
        # assert_select "a:contains(Google)", ["google", "groups"]
        # assert_select "a:contains(Google Groups)", %w[groups]

        # TODO: Currently, `:contains` pseudo-class is not supported.
        # assert_select "a:contains('Google Groups (Link)')", %w[groups]
        # assert_select 'a:contains("(Link)")', %w[groups]
        # assert_select "a:contains(Google Groups (Link))", %w[groups]
        # assert_select "a:contains((Link))", %w[groups]
      end

      def test_pseudo_button
        tmp_div = ::REXML::Element.new("div")
        tmp_div.attributes["id"] = "tmp_input"

        %w[button submit reset].each do |type|
          elements = <<~HTML.lines.map { ::REXML::Document.new(_1).root }
            <input id='input_#{type}' type='#{type}'/>
            <button id='button_#{type}' type='#{type}'>test</button>"
            HTML
          elements.each { tmp_div << _1 }

          # TODO: Currently, `:button`, `:submit`, and `:reset` pseudo-class is not supported.
          # See the following:
          # - https://api.jquery.com/button-selector/
          # - https://api.jquery.com/reset-selector/
          # - https://api.jquery.com/submit-selector/
          # assert_select "#tmp_input, :#{type}", ["input_#{type}", "button_#{type}"]
          # assert CSSSelector.is(elements[0], ":#{type}")
          # assert CSSSelector.is(elements[1], ":#{type}")
        end

        assert true, "dummy"
      end

      def test_pseudo_misc_edge_case
        assert_select "[id='select1'] *:not(:last-child), [id='select2'] *:not(:last-child)",
                      %w[option1a option1b option1c option2a option2b option2c],
                      id("qunit-fixture")

        # TODO: Currently, `:contains` pseudo-class is not supported.
        # assert_select "#qunit-fixture p:has(:contains(mark)):has(code)", %w[ap]
        # assert_select "#qunit-fixture p:has(:contains(mark)):has(code):contains(This link)", %w[ap]

        # TODO: `!=` matcher is not supported because it is jQuery extension.
        # assert_select "p:has(>a.GROUPS[src!=')'])", %w[ap]
        # assert_select "p:has(>a.GROUPS[src!=')'])", %w[ap]
        # TODO: Currently, `:contains` pseudo-class is not supported.
        # assert_select 'p:contains(id="foo")[id!=\\)]', %w[sndp]
        # assert_select "p:contains(id=\"foo\")[id!=')']", %w[sndp]

        assert_select "#ap:has(*), #ap:has(*)", %w[ap]
        assert_select "#nonexistent:has(*), #ap:has(*)", %w[ap]

        # TODO: Currently, `:contains` pseudo-class is not supported.
        # long_selector =
        #   "a[class*=blog]:not(:has(*, :contains(!)), :contains(!)), br:contains(]), p:contains(]), " +
        #   ":not(:empty):not(:parent)"
        # assert_select long_selector, %w[ap mark yahoo simon]
      end

      def test_pseudo_not
        assert_select "a.blog:not(.link)", %w[mark]

        # TODO: Currently, `:contains` pseudo-class is not supported.
        # assert_select "#form option:not(:contains(Nothing),#option1b,:selected)",
        #               %w[option1c option1d option2b option2c option3d option3e option4e option5b option5c]
        # TODO: `:selected` is not supported because it is a jQuery extension.
        # assert_select "#form option:not(:not(:selected))[id^='option3']", %w[option3b option3c]

        assert_select "#qunit-fixture p:not(.foo)", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p:not(div.foo)", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p:not(p.foo)", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p:not(#blargh)", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p:not(div#blargh)", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p:not(p#blargh)", %w[firstp ap sndp en sap first]

        assert_select "#qunit-fixture p:not(a)", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p:not( a )", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p:not( p )", []
        assert_select "#qunit-fixture p:not(a, b)", %w[firstp ap sndp en sap first]
        assert_select "#qunit-fixture p:not(a, b, div)", %w[firstp ap sndp en sap first]
        assert_select "p:not(p)", []
        assert_select "p:not(a,p)", []
        assert_select "p:not(p,a)", []
        assert_select "p:not(a,p,b)", []
        # TODO: `:input`, `:image`, and `:submit` are not supported because they are jQuery extensions.
        # assert_select ":input:not(:image,:input,:submit)", []
        assert_select "#qunit-fixture p:not(:has(a), :nth-child(1))", %w[first]

        assert_select ".container div:not(.excluded) div", []

        assert_select "#form select:not([multiple])", %w[select1 select2 select5]
        assert_select "#form select:not([name=select1])", %w[select2 select3 select4 select5]
        assert_select "#form select:not([name='select1'])", %w[select2 select3 select4 select5]

        assert_select "#foo a:not(.blog)", %w[yahoo anchor2]
        assert_select "#foo a:not(.link)", %w[yahoo anchor2]
        assert_select "#foo a:not(.blog.link)", %w[yahoo anchor2]

        assert_select "#qunit-fixture div[id]:not(:has(div, span)):not(:has(*))",
                      %w[nothiddendivchild divWithNoTabIndex]
        # TODO: Currently, `:button` pseudo-class is not supported.
        # assert_select "#qunit-fixture form[id]:not([action$='formaction']):not(:button)",
        #               %w[lengthtest name-tests testForm]
        # assert_select "#qunit-fixture form[id]:not([action='form:action']):not(:button)",
        #               %w[form lengthtest name-tests testForm]
        # assert_select "#qunit-fixture form[id]:not([action='form:action']:button):not(:input)",
        #               %w[form lengthtest name-tests testForm]
        # TODO: Currently, `:contains` pseudo-class is not supported.
        # assert_select "#form select:not(.select1):contains(Nothing) > option:not(option)", []
      end

      def test_pseudo_form
        extra_text_elements = <<~HTML.lines.map { ::REXML::Document.new(_1).root }
            <input id="impliedText"/>
            <input id="capitalText" type="TEXT" />
            HTML
        form = id("form")
        extra_text_elements.each { form << _1 }

        # TODO: Currently, `:input`, `:radio`, `:checkbox`, and `:text` pseudo-class is not supported.
        # See the following:
        # - https://api.jquery.com/input-selector/
        # - https://api.jquery.com/radio-selector/
        # - https://api.jquery.com/checkbox-selector/
        # - https://api.jquery.com/text-selector/
        # assert_select "#form :input",
        #               %w[
        #                 text1
        #                 text2
        #                 radio1
        #                 radio2
        #                 check1
        #                 check2
        #                 hidden1
        #                 hidden2
        #                 name
        #                 search
        #                 button
        #                 area1
        #                 select1
        #                 select2
        #                 select3
        #                 select4
        #                 select5
        #                 impliedText
        #                 capitalText
        #               ]
        # assert_select "#form :radio", %w[radio1 radio2]
        # assert_select "#form :checkbox", %w[check1 check2]
        # assert_select "#form :text", %w[text1 text2 hidden2 name impliedText capitalText]
        # assert_select "#form :radio:checked", %w[radio2]
        # assert_select "#form :checkbox:checked", %w[check1]
        # assert_select "#form :radio:checked, #form :checkbox:checked", %w[radio2 check1]

        # assert_select "#form option:selected",
        #               %w[option1a option2d option3b option3c option4b option4c option4d option5a]

        # TODO: Currently, implementations of `:checked` and `:enabled` are incomplete.
        # assert_select "#form option:checked",
        #               %w[option1a option2d option3b option3c option4b option4c option4d option5a]
        # assert_select "#hidden1:enabled", %w[hidden1]

        assert true, "dummy"
      end

      def test_pseudo_root
        assert CSSSelector.is(@document.root, ":root")
        assert_select ":root", %w[html]
      end

      def test_cache
        assert_select ":not(code)", %w[google groups anchor1 mark], id("ap")
        assert_select ":not(code)", %w[sndp en yahoo sap anchor2 simon], id("foo")
      end

      def test_more_specific_selector_should_find_less_elements
        assert_operator select_all("#qunit-fixture div div").size, :>=, select_all("#qunit-fixture div div[id]").size
      end
    end
  end
end
