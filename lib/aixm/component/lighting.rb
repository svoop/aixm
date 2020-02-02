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
    class Lighting
      include AIXM::Association
      include AIXM::Mid

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
      }

      INTENSITIES = {
        LIL: :low,
        LIM: :medium,
        LIH: :high,
        OTHER: :other   # specify in remarks
      }

      COLORS = {
        YEL: :yellow,
        RED: :red,
        WHI: :white,
        BLU: :blue,
        GRN: :green,
        PRP: :purple,
        OTHER: :other   # specify in remarks
      }

      # @!method lightable
      #   @return [AIXM::Component::Runway::Direction, AIXM::Component::FATO::Direction, AIXM::Component::Helipad] lighted entity
      belongs_to :lightable

      # @return [Symbol, nil] position of the lighting system (see {POSITIONS})
      attr_reader :position

      # @return [String, nil] detailed description
      attr_reader :description

      # @return [Symbol, nil] intensity of lights (see {INTENSITIES})
      attr_reader :intensity

      # @return [Symbol, nil] color of lights (see {COLORS})
      attr_reader :color

      # @return [String, nil] free text remarks
      attr_reader :remarks

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

      def intensity=(value)
        @intensity = value.nil? ? nil : INTENSITIES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid intensity")
      end

      def color=(value)
        @color = value.nil? ? nil : COLORS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid color")
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] UID markup
      def to_uid(as:)
        builder = Builder::XmlMarkup.new(indent: 2)
        insert_mid(
          builder.tag!(as) do |tag|
            tag << lightable.to_uid.indent(2)
            tag.codePsn(POSITIONS.key(position).to_s)
          end
        )
      end

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
