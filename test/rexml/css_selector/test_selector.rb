# frozen_string_literal: true

require 'test_helper'

module REXML
  class CSSSelector
    class TestVersion < Minitest::Test
      def test_version
        assert_kind_of ::String, ::REXML::CSSSelector::VERSION
      end
    end
  end
end
