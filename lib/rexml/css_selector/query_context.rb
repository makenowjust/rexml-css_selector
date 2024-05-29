# frozen_string_literal: true

module REXML
  module CSSSelector
    # QueryContext is a context on matching CSS selector.
    class QueryContext
      def initialize(scope:, substitutions:, adapter:, options:)
        @scope = scope
        @substitutions = substitutions
        @adapter = adapter
        @options = options
        @cache = {}
      end

      attr_reader :scope, :substitutions, :adapter, :cache, :options

      def scoped(new_scope)
        old_scope = @scope
        @scope = new_scope
        yield
        @scope = old_scope
      end
    end
  end
end
