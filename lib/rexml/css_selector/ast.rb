module REXML
  class CSSSelector
    # Complex/compound/relative selectors:

    SelectorList = Data.define(:selectors)
    ComplexSelector = Data.define(:current, :combinator, :next)
    CompoundSelector = Data.define(:type, :subclasses, :pseudo_elements)
    RelativeSelector = Data.define(:combinator, :next)

    # Type selectors:

    TagNameType = Data.define(:namespace, :tag_name)
    UniversalType = Data.define(:namespace)

    # Subclass selectors:

    Id = Data.define(:name)
    ClassName = Data.define(:name)
    Attribute = Data.define(:namespace, :name, :operator, :value, :modifier)
    PseudoClass = Data.define(:name, :argument)

    Namespace = Data.define(:name)
    UniversalNamespace = Data.define

    # Pseudo element:

    PseudoElement = Data.define(:name, :argument, :pseudo_classes)

    # Arguments:

    RelativeSelectorList = Data.define(:selectors)
    Odd = Data.define
    Even = Data.define
    Nth = Data.define(:a, :b)
    NthOfSelectorList = Data.define(:nth, :selector_list)
    ValueList = Data.define(:values)

    # Value:

    Substitution = Data.define(:name)
    Ident = Data.define(:value)
    String = Data.define(:value)
    Bare = Data.define(:value)
  end
end
