using AIXM::Refinements

module AIXM
  class Component
    class Geometry

      # Starting point of a rhumb line which describes a spiral on a sphere
      # crossing all meridians at the same angle. Defined by {#xy} coordinates.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   point = AIXM.rhumb_line(
      #     xy: AIXM.xy
      #   )
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airspace#rhumb-line
      class RhumbLine
        include AIXM::Association

        # @!method geometry
        #   @return [AIXM::Component::Geometry] geometry this segment belongs to
        belongs_to :geometry, as: :segment

        # (Starting) point
        #
        # @overload xy
        #   @return [AIXM::XY]
        # @overload xy=(value)
        #   @param value [AIXM::XY]
        attr_reader :xy

        # See the {cheat sheet}[AIXM::Component::Geometry::RhumbLine] for
        # examples on how to create instances of this class.
        def initialize(xy:)
          self.xy = xy
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} xy="#{xy}">)
        end

        def xy=(value)
          fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
          @xy = value
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType('RHL')
            avx.geoLat(xy.lat(AIXM.schema))
            avx.geoLong(xy.long(AIXM.schema))
            avx.codeDatum('WGE')
          end
        end
      end

    end
  end
end
