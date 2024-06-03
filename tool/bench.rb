#!/usr/bin/env ruby

# frozen_string_literal: true

require "bundler/setup"

require "benchmark_driver"
require "optparse"

require_relative "../test/fixtures/helper"

filepath = Fixture.filepath("sizzle.html")
selector = "h2, #qunit-fixture p"
bench_rexml_xpath = false
yjit = false

opt = OptionParser.new

opt.on("-f <filepath>") { filepath = _1 }
opt.on("-s <selector>") { selector = _1 }
opt.on("--bench-rexml-xpath") { bench_rexml_xpath = true }
opt.on("--yjit") { yjit = true }

puts "==> Parse command-line options"
opt.parse!(ARGV)

puts <<~HERE
           filepath: #{filepath.inspect}
           selector: #{selector.inspect}
  bench_rexml_xpath: #{bench_rexml_xpath}
               yjit: #{yjit}
  HERE

puts "==> Start a benchmark"

Benchmark.driver do |x|
  x.prelude <<~RUBY
    require "nokogiri"
    require "rexml/document"
    require "rexml/css_selector"

    selector = #{selector.inspect}
    filepath = #{filepath.inspect}
    content = File.read(filepath)
    nokogiri_doc = Nokogiri.HTML(content)
    rexml_doc = REXML::Document.new(content)
    selector_xpath = Nokogiri::CSS.xpath_for(selector).join(" | ")

    #{yjit ? "RubyVM::YJIT.enable" : ""}
    RUBY

  x.report "Nokogiri", " nokogiri_doc.css(selector) "
  x.report "REXML (XPath)", " rexml_doc.get_elements(selector_xpath) " if bench_rexml_xpath
  x.report "REXML::CSSSelector", " REXML::CSSSelector.select_all(rexml_doc, selector) "
end
