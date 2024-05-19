# frozen_string_literal: true

require_relative "lib/rexml/css_selector/version"

Gem::Specification.new do |spec|
  spec.name = "rexml-css-selector"
  spec.version = REXML::CSSSelector::VERSION
  spec.authors = ["Hiroya Fujinami"]
  spec.email = ["make.just.on@gmail.com"]

  spec.summary = "A REXML extension for supporting CSS query selector."
  spec.description = <<~DESCRIPTION
    This library is a REXML extension for supporting CSS query selector.
    It provides both a CSS query selector parser and a matcher.
    DESCRIPTION
  spec.homepage = "https://github.com/makenowjust/rexml-css-selector/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/makenowjust/rexml-css-selector.git"
  spec.metadata["changelog_uri"] = "https://github.com/makenowjust/rexml-css-selector/blob/releases/"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("rexml", ">= 3.2.8")
end
