using AIXM::Refinements

module AIXM
  class Component
    class Geometry

      # Either an individual point or the starting point of a great circle
      # line. Defined by {#xy} coordinates.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   point = AIXM.point(
      #     xy: AIXM.xy
      #   )
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airspace#point
      class Point
        include AIXM::Association

        # @!method geometry
        #   @return [AIXM::Component::Geometry] geometry this segment belongs to
        belongs_to :geometry, as: :segment

        # @return [AIXM::XY] (starting) point
        attr_reader :xy

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
            avx.codeType('GRC')
            avx.geoLat(xy.lat(AIXM.schema))
            avx.geoLong(xy.long(AIXM.schema))
            avx.codeDatum('WGE')
          end
        end
      end

    end
  end
end
