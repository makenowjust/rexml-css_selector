# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rexml/css_selector"

require_relative "fixtures/helper"

require "minitest/autorun"
require "minitest/reporters"

Minitest::Test.make_my_diffs_pretty!
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]
