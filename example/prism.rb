# frozen_string_literal: true

require "prism"
require "rexml/css_selector"
require "rexml/css_selector/adapters/prism_adapter"

program = Prism.parse(File.read(__FILE__)).value
doc = REXML::CSSSelector::Adapters::PrismAdapter::PrismDOM.new(program)
adapter = REXML::CSSSelector::Adapters::PrismAdapter::INSTANCE

REXML::CSSSelector.each_select(doc, 'call[name="require"] > arguments:first-child > string', adapter:) do |element|
  p element.node.content
end
