# frozen_string_literal: true

module REXML
  module CSSSelector
    # PseudoClassDef is a definition of a pseudo class.
    class PseudoClassDef
      def initialize(argument_kind = nil, &compile)
        @argument_kind = argument_kind
        @compile = compile
      end

      attr_reader :argument_kind

      def compile(cont, pseudo_class, compiler)
        @compile.call(cont, pseudo_class, compiler)
      end
    end
  end
end
