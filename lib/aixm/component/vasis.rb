using AIXM::Refinements

module AIXM
  class Component

    # Visual approach slope indicator system
    #
    # ===Cheat Sheet in Pseudo Code:
    #   vasis = AIXM.vasis
    #   vasis.type = TYPES or nil
    #   vasis.position = POSITIONS or nil
    #   vasis.boxes = Integer or nil
    #   vasis.portable = true or false or nil (means: unknown, default)
    #   vasis.slope_angle = AIXM.a or nil
    #   vasis.meht = AIXM.d or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rdn-runway-direction
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#fdn-fato-direction
    class VASIS < Component
      TYPES = {
        PAPI: :precision_api,
        APAPI: :abbreviated_precision_api,
        HAPI: :helicopter_api,
        VASIS: :vasis,
        AVASIS: :abbreviated_vasis,
        TVASIS: :t_shaped_vasis,
        ATVASIS: :abbreviated_t_shaped_vasis,
        OTHER: :other   # specify in remarks
      }.freeze

      POSITIONS = {
        LEFT: :left,
        RIGHT: :right,
        BOTH: :left_and_right,
        OTHER: :other   # specify in remarks
      }.freeze

      # Type of VASIS.
      #
      # @overload type
      #   @return [Symbol, nil] any of {TYPES}
      # @overload type=(value)
      #   @param value [Symbol, nil] any of {TYPES}
      attr_reader :type

      # Position relative to the runway.
      #
      # @overload position
      #   @return [Symbol, nil] any of {POSITIONS}
      # @overload position=(value)
      #   @param value [Symbol, nil] any of {POSITIONS}
      attr_reader :position

      # Number of boxes.
      #
      # @overload boxes
      #   @return [Integer, nil]
      # @overload boxes=(value)
      #   @param value [Integer, nil]
      attr_reader :boxes

      # Whether the VASIS is portable.
      #
      # @overload portable
      #   @return [Boolean, nil] +nil+ means unknown
      # @overload portable=(value)
      #   @param value [Boolean, nil] +nil+ means unknown
      attr_reader :portable

      # Appropriate approach slope angle.
      #
      # @overload slope_angle
      #   @return [AIXM::A, nil]
      # @overload slope_angle=(value)
      #   @param value [AIXM::A, nil]
      attr_reader :slope_angle

      # Minimum eye height over threshold.
      #
      # @overload meht
      #   @return [AIXM::Z, nil]
      # @overload meht=(value)
      #   @param value [AIXM::Z, nil]
      attr_reader :meht

      # @return [String]
      def inspect
        %Q(#<#{self.class} type=#{type.inspect}>)
      end

      def type=(value)
        @type = value.nil? ? nil : TYPES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def position=(value)
        @position = value.nil? ? nil : POSITIONS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid position")
      end

      def boxes=(value)
        fail(ArgumentError, "invalid boxes count") unless value.nil? || (value.is_a?(Integer) && value > 0)
        @boxes = value
      end

      def portable=(value)
        fail(ArgumentError, "invalid portable") unless [true, false, nil].include? value
        @portable = value
      end

      def slope_angle=(value)
        fail(ArgumentError, "invalid slope angle") unless value.nil? || (value.is_a?(AIXM::A) && value.deg <= 90)
        @slope_angle = value
      end

      def meht=(value)
        fail(ArgumentError, "invalid MEHT") unless value.nil? || (value.is_a?(AIXM::Z) && value.qfe?)
        @meht = value
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: true)
        builder.codeTypeVasis(TYPES.key(type).to_s) if type
        builder.codePsnVasis(POSITIONS.key(position).to_s) if position
        builder.noBoxVasis(boxes.to_s) if boxes
        builder.codePortableVasis(portable ? 'Y' : 'N') unless portable.nil?
        builder.valSlopeAngleGpVasis(slope_angle.to_f) if slope_angle
        if meht
          builder.valMeht(meht.alt.to_s)
          builder.uomMeht('FT')
        end
        builder.target!
      end
    end
  end
end
