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
      include AIXM::Association
      include AIXM::Memoize
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

      INTENSITIES = {
        LIL: :low,
        LIM: :medium,
        LIH: :high,
        OTHER: :other   # specify in remarks
      }.freeze

      # @!method approach_lightable
      #   @return [AIXM::Component::Runway::Direction, AIXM::Component::FATO::Direction] approach lighted entity
      belongs_to :approach_lightable

      # @return [Symbol, nil] type of the approach lighting system (see {TYPES})
      attr_reader :type

      # @return [AIXM::D, nil] length
      attr_reader :length

      # @return [Symbol, nil] intensity of lights (see {INTENSITIES})
      attr_reader :intensity

      # @return [Boolean, nil] whether sequenced flash is available
      attr_reader :sequenced_flash

      # @return [String, nil] description of the flash sequence
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

      def intensity=(value)
        @intensity = value.nil? ? nil : INTENSITIES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid intensity")
      end

      def sequenced_flash=(value)
        fail(ArgumentError, "invalid sequenced flash") unless [true, false, nil].include? value
        @sequenced_flash = value
      end

      def flash_description=(value)
        @flash_description = value&.to_s
      end

      # @return [String] UID markup
      def to_uid(as:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag << approach_lightable.to_uid.indent(2)
          tag.codeType(TYPES.key(type).to_s)
        end
      end
      memoize :to_uid

      # @return [String] AIXM or OFMX markup
      def to_xml(as:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag << to_uid(as: "#{as}Uid").indent(2)
          if length
            tag.valLen(length.dim.round)
            tag.uomLen(length.unit.to_s.upcase)
          end
          tag.codeIntst(INTENSITIES.key(intensity).to_s) if intensity
          tag.codeSequencedFlash(sequenced_flash ? 'Y' : 'N') unless sequenced_flash.nil?
          tag.txtDescrFlash(flash_description) if flash_description
          tag.txtRmk(remarks) if remarks
        end
        builder.target!
      end
    end
  end
end
