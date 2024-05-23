# frozen_string_literal: true

require 'rexml/document'
require 'strscan'

module REXML
  class CSSSelector
    class Error < ::StandardError
    end
  end
end

require_relative 'css_selector/ast'
require_relative 'css_selector/parser'
require_relative 'css_selector/version'
