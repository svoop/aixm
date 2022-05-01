using AIXM::Refinements

module AIXM
  class Component

    # Approach lighting system (ALS)
    #
    # ===Cheat Sheet in Pseudo Code:
    #   approach_lighting = AIXM.approach_lighting(
    #     type: TYPES
    #   )
    #   approach_lighting.length = AIXM.d or nil
    #   approach_lighting.intensity = INTENSITIES or nil
    #   approach_lighting.sequenced_flash = true or false or nil (means: unknown, default)
    #   approach_lighting.flash_description = String or nil
    #   approach_lighting.remarks = String or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rda-runway-direction-approach-lighting
    class ApproachLighting < Component
      include AIXM::Concerns::Association
      include AIXM::Concerns::Intensity
      include AIXM::Concerns::Remarks

      TYPES = {
        A: :cat_1,
        B: :cat_2,
        C: :cat_3,
        D: :cat_2_and_3,
        E: :simple,
        F: :circling,
        G: :alignment,
        ALSAF: :high_intensity,
        MALS: :medium_intensity,
        MALSR: :medium_intensity_with_alignment,
        SALS: :short,
        SSALS: :simplified_short,
        SSALR: :simplified_short_with_alignment,
        LDIN: :lead_in,
        ODALS: :omni_directional,
        AFOVRN: :usaf_overrun,
        MILOVRN: :military_overrun,
        OTHER: :other   # specify in remarks
      }.freeze

      # @!method approach_lightable
      #   @return [AIXM::Component::Runway::Direction, AIXM::Component::FATO::Direction] approach lighted entity
      belongs_to :approach_lightable

      # Type of the approach lighting system
      #
      # @overload type
      #   @return [Symbol] any of {TYPES}
      # @overload type=(value)
      #   @param value [Symbol] any of {TYPES}
      attr_reader :type

      # Length
      #
      # @overload length
      #   @return [AIXM::D, nil]
      # @overload length=(value)
      #   @param value [AIXM::D, nil]
      attr_reader :length

      # Whether sequenced flash is available
      #
      # @overload sequenced_flash
      #   @return [Boolean, nil] +nil+ means unknown
      # @overload sequenced_flash=(value)
      #   @param value [Boolean, nil] +nil+ means unknown
      attr_reader :sequenced_flash

      # Description of the flash sequence
      #
      # @overload flash_description
      #   @return [String, nil]
      # @overload flash_description=(value)
      #   @param value [String, nil]
      attr_reader :flash_description

      # See the {cheat sheet}[AIXM::Component::ApproachLighting] for examples on
      # how to create instances of this class.
      def initialize(type:)
        self.type = type
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} type=#{type.inspect}>)
      end

      def type=(value)
        @type = TYPES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def length=(value)
        fail(ArgumentError, "invalid length") unless value.nil? || value.is_a?(AIXM::D)
        @length = value
      end

      def sequenced_flash=(value)
        fail(ArgumentError, "invalid sequenced flash") unless [true, false, nil].include? value
        @sequenced_flash = value
      end

      def flash_description=(value)
        @flash_description = value&.to_s
      end

      # @!visibility private
      def add_uid_to(builder, as:)
        builder.send(as) do |tag|
          approach_lightable.add_uid_to(tag)
          tag.codeType(TYPES.key(type))
        end
      end

      # @!visibility private
      def add_to(builder, as:)
        builder.send(as) do |tag|
          add_uid_to(tag, as: "#{as}Uid")
          if length
            tag.valLen(length.dim.round)
            tag.uomLen(length.unit.to_s.upcase)
          end
          tag.codeIntst(INTENSITIES.key(intensity)) if intensity
          tag.codeSequencedFlash(sequenced_flash ? 'Y' : 'N') unless sequenced_flash.nil?
          tag.txtDescrFlash(flash_description) if flash_description
          tag.txtRmk(remarks) if remarks
        end
      end
    end
  end
end
