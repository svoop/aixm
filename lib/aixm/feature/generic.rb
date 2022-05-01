using AIXM::Refinements

module AIXM
  class Feature

    # Generic feature represented as XML document fragment.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   generic = AIXM.generic(
    #     fragment: Nokogiri::XML::DocumentFragment or String
    #   )
    class Generic < Feature
      public_class_method :new

      # XML document fragment
      #
      # @overload fragment
      #   @return [Nokogiri::XML::DocumentFragment]
      # @overload fragment=(value)
      #   @param value [Nokogiri::XML::DocumentFragment, Object] XML document
      #     fragment or object which is converted to string and then parsed
      attr_reader :fragment

      # See the {cheat sheet}[AIXM::Feature::Generic] for examples on how to
      # create instances of this class.
      def initialize(source: nil, region: nil, fragment:)
        super(source: source, region: region)
        self.fragment = fragment
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} #{fragment.elements.first.name}>)
      end

      def fragment=(value)
        @fragment = case value
          when Nokogiri::XML::DocumentFragment then value
          else Nokogiri::XML::DocumentFragment.parse(value.to_s)
        end
      end

      # @return [Integer] pseudo UID fragment
      def to_uid
        fragment.to_xml.hash
      end

      # @!visibility private
      def add_to(builder)
        builder.comment "Generic".dress
        builder.text "\n"
        if comment
          builder.comment(indented_comment)
          builder.text "\n"
        end
        builder << fragment
      end
    end

  end
end
