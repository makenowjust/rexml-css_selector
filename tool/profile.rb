#!/usr/bin/env ruby

# frozen_string_literal: true

require "bundler/setup"

require "optparse"
require "rexml/document"
require "rexml/css_selector"
require "stackprof"

require_relative "../test/fixtures/helper"

filepath = Fixture.filepath("sizzle.html")
selector = "h2, #qunit-fixture p"
out = "tmp/profile-#{Time.now.strftime("%Y%m%d%H%M%S")}.dump"
n = 1000

opt = OptionParser.new

opt.on("-f <filepath>") { filepath = _1 }
opt.on("-s <selector>") { selector = _1 }
opt.on("-n <n>") { n = _1.to_i }
opt.on("-o <filepath>") { out = _1 }

puts "==> Parse command-line options"
opt.parse!(ARGV)

puts <<~HERE
  filepath: #{filepath.inspect}
  selector: #{selector.inspect}
         n: #{n}
       out: #{out.inspect}
  HERE

puts "==> Load and parse a XML file"

content = File.read(filepath)
doc = REXML::Document.new(content)

puts "==> Start a profile"

StackProf.run(mode: :cpu, raw: true, out:) do
  n.times do |i|
    REXML::CSSSelector.select_all(doc, selector)
    print "." if (i % 100).zero?
  end
end

puts
puts "==> Finish a profile"

puts
puts "==> Generate flamegraph HTML"

File.open("#{out}.html", "w") { |f| StackProf::Report.from_file(out).print_d3_flamegraph(f) }
