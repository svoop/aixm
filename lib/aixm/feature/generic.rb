module AIXM
  class Feature

    # Generic feature represented as fragment (raw XML source code).
    #
    # ===Cheat Sheet in Pseudo Code:
    #   generic = AIXM.generic(
    #     fragment: String
    #   )
    class Generic < Feature
      include AIXM::Memoize

      public_class_method :new

      # XML document fragment
      #
      # @note Any object is accepted and will receive +to_s+ before being
      #   parsed into an XML fragment.
      #
      # @overload fragment
      #   @return [Nokogiri::XML::DocumentFragment]
      # @overload fragment=(value)
      #   @param value [Object] raw XML source
      attr_reader :fragment

      # See the {cheat sheet}[AIXM::Feature::Generic] for examples on how to
      # create instances of this class.
      def initialize(source: nil, region: nil, fragment:)
        super(source: source, region: region)
        self.fragment = fragment
      end

      # @return [String]
      def inspect
        '#<' + [self.class, fragment.first_element_child&.name].join(' ') + '>'
      end

      def fragment=(value)
        @fragment = Nokogiri::XML::DocumentFragment.parse(value.to_s, &:noblanks)
      end

      # @return [String] hashed XML as pseudo UID
      def to_uid
        to_xml.hash
      end
      memoize :to_uid

      # @return [String] AIXM or OFMX markup
      def to_xml
        fragment.children
          .map { _1.to_xml(indent: 2) }
          .prepend("<!-- Generic -->")
          .join("\n")
          .concat("\n")
      end
    end

  end
end
