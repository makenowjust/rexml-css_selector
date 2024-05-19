# frozen_string_literal: true

require "test_helper"

class REXML::CSSSelector::TestVersion < Minitest::Test
  def test_version
    assert_kind_of String, ::REXML::CSSSelector::VERSION
  end
end
