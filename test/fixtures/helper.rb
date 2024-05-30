# frozen_string_literal: true
module Fixture
  def self.filepath(filename) = "#{__dir__}/#{filename}"

  def self.load(filename) = REXML::Document.new(File.read(filepath(filename)))

  def self.load_nwmatcher = load("nwmatcher.html")
  def self.load_qwery = load("qwery.html")

  def self.load_sizzle = load("sizzle.html")
  def self.load_sizzle_xml = load("fries.xml")

  module Helper
    def select(selector, scope = @document, **config)
      REXML::CSSSelector.select(scope, selector, **config)
    end

    def select_all(selector, scope = @document, **config)
      REXML::CSSSelector.select_all(scope, selector, **config)
    end

    def id(id, document: @document)
      ids(id, document:).first
    end

    def ids(*ids, document: @document)
      condition = ids.map { |id| "@id=\"#{id}\"" }.join(" or ")
      elements = []
      document.each_element("//*[#{condition}]") { |element| elements << element }
      elements
    end
  end
end
