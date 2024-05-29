# `REXML::CSSSelector`

> A REXML extension for supporting CSS selector.

## Installation

This library has not been published on RubyGems yet.

You can use this library via GitHub source.
Please add the following line to your `Gemfile`.

```ruby
gem 'rexml-css_selector', :git => 'git://github.com/makenowjust/rexml-css_selector.git'
```

## Usage

The main API of this library is `REXML::CSSSelector.each_select`.
`REXML::CSSSelector.each_select(scope, selector)` takes two arguments: `scope` is a scope node which it starts matching from, and `selector` is a CSS selector string.
Then, it calls the given block with a matched node.

See the example.

```ruby
require "rexml/document"
require "rexml/css_selector"

# From https://www.w3schools.com/xml/note.xml.
doc = REXML::Document.new(<<~XML)
  <?xml version="1.0" encoding="UTF-8"?>
  <note>
    <script/>
    <to>Tove</to>
    <from>Jani</from>
    <heading>Reminder</heading>
    <body>Don't forget me this weekend!</body>
  </note>
  XML

# "script ~ *" selects sibling elements after a `<script>` tag.
REXML::CSSSelector.each_select(doc, "script ~ *") do |element|
  p element
end

# Output:
# <to> ... </>
# <from> ... </>
# <heading> ... </>
# <body> ... </>
```

This library also provides the following APIs:

- `REXML::CSSSelector.select(scope, selector)`: Returns the first matched element.
- `REXML::CSSSelector.select_all(scope, selector)`: Returns an array of matched elements.
- `REXML::CSSSelector.is(node, selector, scope: node.document)`: Checks whether `node` matches `selector` from `scope`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/makenowjust/rexml-css_selector>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/makenowjust/rexml-css_selector/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rexml::Css::Selector project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/makenowjust/rexml-css_selector/blob/main/CODE_OF_CONDUCT.md).
