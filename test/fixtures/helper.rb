# frozen_string_literal: true
module Fixture
  def self.load(filename) = REXML::Document.new(File.read("#{__dir__}/#{filename}"))

  def self.load_nwmatcher = load("nwmatcher.html")
  def self.load_qwery = load("qwery.html")

  def self.load_sizzle = load("sizzle.html")
  def self.load_sizzle_xml = load("fries.xml")
end
