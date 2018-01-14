module AIXM
  module Vertical

    ##
    # Vertical limits
    #
    # Normally noted as:
    #
    #   +upper z+ (or +max_z+ whichever is higher)
    #   ---------
    #   +lower_z+ (or +min_z+ whichever is lower)
    #
    # Use +AIXM::GROUND+ as a shortcut for surface aka zero height.
    class Limits

      using AIXM::Refinements

      TAGS = { upper: :Upper, lower: :Lower, max: :Max, min: :Mnm }.freeze
      CODES = { QFE: :HEI, QNH: :ALT, QNE: :STD }.freeze

      attr_reader :upper_z, :lower_z, :max_z, :min_z

      ##
      # Defines vertical limits +upper_z+ and +lower_z+
      #
      # Options:
      # * +max_z+ - alternative upper limit "whichever is higher"
      # * +min_z+ - alternative lower limit "whichever is lower"
      def initialize(upper_z:, lower_z:, max_z: nil, min_z: nil)
        fail(ArgumentError, "invalid upper_z") unless upper_z.is_a? AIXM::Z
        fail(ArgumentError, "invalid lower_z") unless lower_z.is_a? AIXM::Z
        fail(ArgumentError, "invalid max_z") unless max_z.nil? || max_z.is_a?(AIXM::Z)
        fail(ArgumentError, "invalid min_z") unless min_z.nil? || min_z.is_a?(AIXM::Z)
        @upper_z, @lower_z, @max_z, @min_z = upper_z, lower_z, max_z, min_z
      end

      ##
      # Digest to identify the payload
      def to_digest
        [upper_z.alt, upper_z.code, lower_z.alt, lower_z.code, max_z&.alt, max_z&.code, min_z&.alt, min_z&.code].to_digest
      end

      ##
      # Render AIXM
      #
      # Extensions:
      # * +:OFM+ - Open Flightmaps
      def to_xml(*extensions)
        %i(upper lower max min).each_with_object(Builder::XmlMarkup.new(indent: 2)) do |limit, builder|
          if z = send(:"#{limit}_z")
            builder.tag!(:"codeDistVer#{TAGS[limit]}", CODES[z.code].to_s)
            builder.tag!(:"valDistVer#{TAGS[limit]}", z.alt.to_s)
            builder.tag!(:"uomDistVer#{TAGS[limit]}", z.unit.to_s)
          end
        end.target!   # see https://github.com/jimweirich/builder/issues/42
      end
    end
  end
end
