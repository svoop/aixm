using AIXM::Refinements

module AIXM
  class Component

    # Vertical limits define a 3D airspace vertically. They are often noted in
    # AIP as follows:
    #
    #   +upper z+ (or +max_z+ whichever is higher)
    #   ---------
    #   +lower_z+ (or +min_z+ whichever is lower)
    #
    # ===Cheat Sheet in Pseudo Code:
    #   vertical_limits = AIXM.vertical_limits(
    #     upper_z: AIXM.z
    #     lower_z: AIXM.z
    #     max_z: AIXM.z or nil
    #     min_z: AIXM.z or nil
    #   )
    #
    # ===Shortcuts:
    # * +AIXM::GROUND+ - surface expressed as "0 ft QFE"
    # * +AIXM::UNLIMITED+ - no upper limit expressed as "FL 999"
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airspace#ase-airspace
    class VerticalLimits
      # @api private
      TAGS = { upper: :Upper, lower: :Lower, max: :Max, min: :Mnm }.freeze

      # @api private
      CODES = { qfe: :HEI, qnh: :ALT, qne: :STD }.freeze

      # @return [AIXM::Z] upper limit
      attr_reader :upper_z

      # @return [AIXM::Z] lower limit
      attr_reader :lower_z

      # @return [AIXM::Z] alternative upper limit ("whichever is higher")
      attr_reader :max_z

      # @return [AIXM::Z] alternative lower limit ("whichever is lower")
      attr_reader :min_z

      def initialize(upper_z:, lower_z:, max_z: nil, min_z: nil)
        self.upper_z, self.lower_z, self.max_z, self.min_z = upper_z, lower_z, max_z, min_z
      end

      def upper_z=(value)
        fail(ArgumentError, "invalid upper_z") unless value.is_a? AIXM::Z
        @upper_z = value
      end

      def lower_z=(value)
        fail(ArgumentError, "invalid lower_z") unless value.is_a? AIXM::Z
        @lower_z = value
      end

      def max_z=(value)
        fail(ArgumentError, "invalid max_z") unless value.nil? || value.is_a?(AIXM::Z)
        @max_z = value
      end

      def min_z=(value)
        fail(ArgumentError, "invalid min_z") unless value.nil? || value.is_a?(AIXM::Z)
        @min_z = value
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} upper_z="#{upper_z.to_s}" lower_z="#{lower_z.to_s}">)
      end

      # @return [String] AIXM or OFMX markup
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
