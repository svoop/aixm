using AIXM::Refinements

module AIXM
  class Feature

    # Generic feature represented as fragment (raw XML source code).
    #
    # ===Cheat Sheet in Pseudo Code:
    #   generic = AIXM.generic(
    #     xml: Object
    #   )
    class Generic < Feature
      public_class_method :new

      # Raw XML source
      #
      # @note Any object is accepted, it will be converted to String using
      #   +to_s+.
      #
      # @overload xml
      #   @return [String]
      # @overload xml=(value)
      #   @param value [Object] raw XML source
      attr_reader :xml

      # See the {cheat sheet}[AIXM::Feature::Generic] for examples on how to
      # create instances of this class.
      def initialize(source: nil, region: nil, xml:)
        super(source: source, region: region)
        self.xml = xml
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} "#{xml.lines.first}…">)
      end

      def xml=(value)
        @xml = value.to_s
      end

      # @return [Integer] pseudo UID fragment
      def to_uid
        xml.hash
      end

      # @!visibility private
      def add_to(builder)
        builder.comment "Generic".dress
        builder.text "\n"
        if comment
          builder.comment(indented_comment)
          builder.text "\n"
        end
        builder << xml
      end
    end

  end
end
