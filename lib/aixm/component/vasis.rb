using AIXM::Refinements

module AIXM
  module Component

    # Visual approach slope indicator system
    #
    # ===Cheat Sheet in Pseudo Code:
    #   vasis = AIXM.vasis
    #   vasis.type = TYPES or nil
    #   vasis.position = POSITIONS or nil
    #   vasis.boxes_count = Integer or nil
    #   vasis.portable = true or false or nil (means: unknown, default)
    #   vasis.slope_angle = AIXM.a or nil
    #   vasis.meht = AIXM.d or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rdn-runway-direction
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#fdn-fato-direction
    class VASIS
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

      # @return [Symbol, nil] type of VASIS (see {TYPES})
      attr_reader :type

      # @return [Symbol, nil] position relative to the runway (see {POSITIONS})
      attr_reader :position

      # @return [Integer, nil] number of boxes
      attr_reader :boxes_count

      # @return [Boolean, nil] whether the VASIS is portable
      attr_reader :portable

      # @return [AIXM::A, nil] appropriate approach slope angle
      attr_reader :slope_angle

      # @return [AIXM::Z, nil] minimum eye height over threshold (MEHT)
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

      def boxes_count=(value)
        fail(ArgumentError, "invalid boxes count") unless value.nil? || (value.is_a?(Integer) && value > 0)
        @boxes_count = value
      end

      def portable=(value)
        fail(ArgumentError, "invalid portable") unless [true, false, nil].include? value
        @portable = value
      end

      def slope_angle=(value)
        fail(ArgumentError, "invalid slope angle") unless value.nil? || (value.is_a?(AIXM::A) && value.precision == 3 && value.deg <= 90)
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
        builder.noBoxVasis(boxes_count.to_s) if boxes_count
        builder.codePortableVasis(portable ? 'Y' : 'N') unless portable.nil?
        builder.valSlopeAngleGpVasis(slope_angle.deg.to_s) if slope_angle
        if meht
          builder.valMeht(meht.alt.to_s)
          builder.uomMeht('FT')
        end
        builder.target!
      end
    end
  end
end
