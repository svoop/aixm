using AIXM::Refinements

module AIXM
  module Component

    ##
    # Vertical limits define a 3D airspace vertically. They are normally noted
    # as follows:
    #
    #   +upper z+ (or +max_z+ whichever is higher)
    #   ---------
    #   +lower_z+ (or +min_z+ whichever is lower)
    #
    # Shortcuts:
    # * +AIXM::GROUND+ - surface (aka: 0ft QFE)
    # * +AIXM::UNLIMITED+ - no upper limit (aka: FL 999)
    class VerticalLimits
      TAGS = { upper: :Upper, lower: :Lower, max: :Max, min: :Mnm }.freeze
      CODES = { qfe: :HEI, qnh: :ALT, qne: :STD }.freeze

      attr_reader :upper_z, :lower_z, :max_z, :min_z

      def initialize(max_z: nil, upper_z:, lower_z:, min_z: nil)
        fail(ArgumentError, "invalid upper_z") unless upper_z.is_a? AIXM::Z
        fail(ArgumentError, "invalid lower_z") unless lower_z.is_a? AIXM::Z
        fail(ArgumentError, "invalid max_z") unless max_z.nil? || max_z.is_a?(AIXM::Z)
        fail(ArgumentError, "invalid min_z") unless min_z.nil? || min_z.is_a?(AIXM::Z)
        @upper_z, @lower_z, @max_z, @min_z = upper_z, lower_z, max_z, min_z
      end

      def inspect
        %Q(#<#{self.class} upper_z="#{upper_z.to_s}" lower_z="#{lower_z.to_s}">)
      end

      def to_xml
        %i(upper lower max min).each_with_object(Builder::XmlMarkup.new(indent: 2)) do |limit, builder|
          if z = send(:"#{limit}_z")
            builder.tag!(:"codeDistVer#{TAGS[limit]}", CODES[z.code].to_s)
            builder.tag!(:"valDistVer#{TAGS[limit]}", z.alt.to_s)
            builder.tag!(:"uomDistVer#{TAGS[limit]}", z.unit.to_s)
          end
        end.target!
      end
    end

  end
end
