# frozen_string_literal: true

module REXML
  module CSSSelector
    # Complex/compound/relative selectors:

    # SelectorList is a list of selectors.
    #
    # This is corresponding to a comma operator (<tt>..., ...</tt>) in CSS selector.
    SelectorList = Data.define(:selectors)

    # ComplexSelector is a pair of selectors with a combinator.
    #
    # This is corresponding to descendant/adjacent/sibling operators in CSS selector.
    ComplexSelector = Data.define(:left, :combinator, :right)

    # CompoundSelector is a compound selector.
    CompoundSelector = Data.define(:type, :subclasses, :pseudo_elements)

    # RelativeSelector is a pair of a combinator and a selector.
    RelativeSelector = Data.define(:combinator, :right)

    # Type selectors:

    # TagNameType is a type selector of a tag name.
    TagNameType = Data.define(:namespace, :tag_name)

    # UniversalType is the universal type selector (<tt>*</tt>).
    UniversalType = Data.define(:namespace)

    # Subclass selectors:

    # Id is an ID selector (e.g. <tt>#name</tt>).
    Id = Data.define(:name)

    # ClassName is a class name selector (e.g. <tt>.name</tt>).
    ClassName = Data.define(:name)

    # Attribute is an attribute selector (e.g. <tt>[name]</tt>, <tt>[name=value]</tt>).
    #
    # If +matcher+, +value+, and +modifier+ is +nil+, it means an attribute presence selector (e.g. <tt>[name]</tt>).
    #
    # +matcher+ takes one of the following values:
    #
    # - <tt>:"="</tt>
    # - <tt>:"~="</tt>
    # - <tt>:"|="</tt>
    # - <tt>:"^="</tt>
    # - <tt>:"$="</tt>
    # - <tt>:"*="</tt>
    #
    # +modifier+ takes one of the following values:
    #
    # - <tt>:i</tt>
    # - <tt>:s</tt>
    # - <tt>nil</tt>
    Attribute = Data.define(:namespace, :name, :matcher, :value, :modifier)

    # PseudoClass ia a pseudo class selector (e.g. <tt>:first-child</tt>).
    PseudoClass = Data.define(:name, :argument)

    # Namespace is a namespace in CSS selector.
    Namespace = Data.define(:name)

    # UniversalNamespace is the universal namespace in CSS selector.
    UniversalNamespace = Data.define

    # Pseudo element:

    # PseudoElement is a pseudo element.
    PseudoElement = Data.define(:name, :argument, :pseudo_classes)

    # Arguments:

    # RelativeSelectorList is a list of relative selectors.
    RelativeSelectorList = Data.define(:selectors)

    # Odd is +odd+ in a <tt>:nth-child</tt> argument.
    Odd = Data.define

    # Even is +even+ in a <tt>:nth-child</tt> argument.
    Even = Data.define

    # Nth is <tt>An+B</tt> in a <tt>:nth-child</tt> argument.
    Nth = Data.define(:a, :b)

    # NthOfSelectorList is <tt>An+B of S</tt> in a <tt>:nth-child</tt> argument.
    NthOfSelectorList = Data.define(:nth, :selector_list)

    # ValueList is a list of values.
    ValueList = Data.define(:values)

    # Value:

    # Substitution is a placeholder value which is replaced by +substitutions[name]+ on run-time.
    Substitution = Data.define(:name)

    # Ident is a ident value.
    Ident = Data.define(:value)

    # String is a string value.
    String = Data.define(:value)

    # Bare is a bare value.
    Bare = Data.define(:value)
  end
end
