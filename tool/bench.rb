# frozen_string_literal: true

require "benchmark"
require "nokogiri"
require "optparse"
require "rexml/document"
require "rexml/css_selector"

require_relative "../test/fixtures/helper"

filepath = Fixture.filepath("sizzle.html")
selector = "h2, #qunit-fixture p"
bench_rexml_xpath = false
n = 1000

opt = OptionParser.new

opt.on("-f <filepath>") { filepath = _1 }
opt.on("-s <selector>") { selector = _1 }
opt.on("-n <n>") { n = _1.to_i }
opt.on("--bench-rexml-xpath") { bench_rexml_xpath = true }

puts "==> Parse command-line options"
opt.parse!(ARGV)

puts <<~HERE
           filepath: #{filepath.inspect}
           selector: #{selector.inspect}
                  n: #{n}
  bench_rexml_xpath: #{bench_rexml_xpath}
  HERE

puts "==> Load and parse a XML file"

content = File.read(filepath)
nokogiri_doc = Nokogiri.HTML(content)
rexml_doc = REXML::Document.new(content)

if bench_rexml_xpath
  selector_xpath = Nokogiri::CSS.xpath_for(selector).join(" | ")
  puts "   XPath: #{selector_xpath}"
end

puts "==> Start a benchmark"

Benchmark.bm do |x|
  x.report("Nokogiri          ") { n.times { nokogiri_doc.css(selector) } }
  x.report("REXML (XPath)     ") { n.times { rexml_doc.get_elements(selector_xpath) } } if bench_rexml_xpath
  x.report("REXML::CSSSelector") { n.times { REXML::CSSSelector.select_all(rexml_doc, selector) } }
end
