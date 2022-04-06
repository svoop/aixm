using AIXM::Refinements

module AIXM
  class Component

    # Lighting of a runway, helipad etc
    #
    # ===Cheat Sheet in Pseudo Code:
    #   lighting = AIXM.lighting(
    #     position: POSITIONS
    #   )
    #   lighting.description = String or nil
    #   lighting.intensity = INTENSITIES or nil
    #   lighting.color = COLORS or nil
    #   lighting.remarks = String or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rls-runway-direction-lighting
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#fls-fato-direction-lighting
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#tls-helipad-tlof-lighting
    class Lighting < Component
      include AIXM::Association
      include AIXM::Memoize
      include AIXM::Concerns::Intensity
      include AIXM::Concerns::Remarks

      POSITIONS = {
        TDZ: :touch_down_zone,
        AIM: :aiming_point,
        CL: :center_line,
        EDGE: :edge,
        THR: :threshold,
        SWYEDGE: :stopway_edge,
        DESIG: :runway_designation,
        AFTTHR: :after_threshold,
        DISPTHR: :displaced_threshold,
        SWYCL: :stopway_center_line,
        END: :runway_end,
        SWYEND: :stopway_end,
        TWYINT: :taxiway_intersection,
        HOLDBAY: :taxyway_hold_bay,
        RTWYINT: :rapid_taxiway_intersection,
        OTHER: :other   # specify in remarks
      }.freeze

      COLORS = {
        YEL: :yellow,
        RED: :red,
        WHI: :white,
        BLU: :blue,
        GRN: :green,
        PRP: :purple,
        OTHER: :other   # specify in remarks
      }.freeze

      # @!method lightable
      #   @return [AIXM::Component::Runway::Direction, AIXM::Component::FATO::Direction, AIXM::Component::Helipad] lighted entity
      belongs_to :lightable

      # Position of the lighting system
      #
      # @overload position
      #   @return [Symbol, nil] any of {POSITIONS}
      # @overload position=(value)
      #   @param value [Symbol, nil] any of {POSITIONS}
      attr_reader :position

      # Detailed description
      #
      # @overload description
      #   @return [String, nil]
      # @overload description=(value)
      #   @param value [String, nil]
      attr_reader :description

      # Color of lights
      #
      # @overload color
      #   @return [Symbol, nil] any of {COLORS}
      # @overload color=(value)
      #   @param value [Symbol, nil] any of {COLORS}
      attr_reader :color

      # See the {cheat sheet}[AIXM::Component::Lighting] for examples on how to
      # create instances of this class.
      def initialize(position:)
        self.position = position
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} position=#{position.inspect}>)
      end

      def position=(value)
        @position = POSITIONS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid position")
      end

      def description=(value)
        @description = value&.to_s
      end

      def color=(value)
        @color = value.nil? ? nil : COLORS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid color")
      end

      # @return [String] UID markup
      def to_uid(as:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag << lightable.to_uid.indent(2)
          tag.codePsn(POSITIONS.key(position).to_s)
        end
      end
      memoize :to_uid

      # @return [String] AIXM or OFMX markup
      def to_xml(as:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag << to_uid(as: "#{as}Uid").indent(2)
          tag.txtDescr(description) if description
          tag.codeIntst(INTENSITIES.key(intensity).to_s) if intensity
          tag.codeColour(COLORS.key(color).to_s) if color
          tag.txtRmk(remarks) if remarks
        end
        builder.target!
      end
    end
  end
end
