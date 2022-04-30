using AIXM::Refinements

module AIXM
  class Component

    # Vertical limit defines a 3D airspace vertically. It is often noted in
    # AIP as follows:
    #
    #   upper_z
    #   (max_z)   whichever is higher
    #   -------
    #   lower_z
    #   (min_z)   whichever is lower
    #
    # ===Cheat Sheet in Pseudo Code:
    #   vertical_limit = AIXM.vertical_limit(
    #     upper_z: AIXM.z
    #     max_z: AIXM.z or nil
    #     lower_z: AIXM.z
    #     min_z: AIXM.z or nil
    #   )
    #
    # ===Shortcuts:
    # * +AIXM::GROUND+ - surface expressed as "0 ft QFE"
    # * +AIXM::UNLIMITED+ - no upper limit expressed as "FL 999"
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airspace#ase-airspace
    class VerticalLimit < Component
      include AIXM::Association

      # @api private
      TAGS = { upper_z: :Upper, lower_z: :Lower, max_z: :Max, min_z: :Mnm }.freeze

      # @api private
      CODES = { qfe: :HEI, qnh: :ALT, qne: :STD }.freeze

      # @!method layer
      #   @return [AIXM::Component::Layer] layer to which this vertical limit applies
      belongs_to :layer

      # Upper limit
      #
      # @overload upper_z
      #   @return [AIXM::Z]
      # @overload upper_z=(value)
      #   @param value [AIXM::Z]
      attr_reader :upper_z

      # Lower limit
      #
      # @overload lower_z
      #   @return [AIXM::Z]
      # @overload lower_z=(value)
      #   @param value [AIXM::Z]
      attr_reader :lower_z

      # Alternative upper limit ("whichever is higher")
      #
      # @overload max_z
      #   @return [AIXM::Z, nil]
      # @overload max_z=(value)
      #   @param value [AIXM::Z, nil]
      attr_reader :max_z

      # Alternative lower limit ("whichever is lower")
      #
      # @overload min_z
      #   @return [AIXM::Z, nil]
      # @overload min_z=(value)
      #   @param value [AIXM::Z, nil]
      attr_reader :min_z

      # See the {cheat sheet}[AIXM::Component::VerticalLimit] for examples on
      # how to create instances of this class.
      def initialize(upper_z:, max_z: nil, lower_z:, min_z: nil)
        self.upper_z, self.max_z, self.lower_z, self.min_z = upper_z, max_z, lower_z, min_z
      end

      # @return [String]
      def inspect
        payload = %i(upper_z max_z lower_z min_z).map { %Q(#{_1}="#{send(_1)}") if send(_1) }.compact
        %Q(#<#{self.class} #{payload.join(' '.freeze)}>)
      end

      def upper_z=(value)
        fail(ArgumentError, "invalid upper_z") unless value.is_a? AIXM::Z
        @upper_z = value
      end

      def max_z=(value)
        fail(ArgumentError, "invalid max_z") unless value.nil? || value.is_a?(AIXM::Z)
        @max_z = value
      end

      def lower_z=(value)
        fail(ArgumentError, "invalid lower_z") unless value.is_a? AIXM::Z
        @lower_z = value
      end

      def min_z=(value)
        fail(ArgumentError, "invalid min_z") unless value.nil? || value.is_a?(AIXM::Z)
        @min_z = value
      end

      # @!visibility private
      def add_to(builder)
        TAGS.each_key do |limit|
          if z = send(limit)
            builder.send(:"codeDistVer#{TAGS[limit]}", CODES[z.code])
            builder.send(:"valDistVer#{TAGS[limit]}", z.alt)
            builder.send(:"uomDistVer#{TAGS[limit]}", z.unit.upcase)
          end
        end
      end
    end

  end
end
