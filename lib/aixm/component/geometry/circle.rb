using AIXM::Refinements

module AIXM
  module Component
    class Geometry

      # Circles are defined by a {#center_xy} and a {#radius}.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   circle = AIXM.circle(
      #     center_xy: AIXM.xy
      #     radius: AIXM.d
      #   )
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airspace#circle
      class Circle
        include AIXM::Association

        # @!method geometry
        #   @return [AIXM::Component::Geometry] geometry the arc belongs to
        belongs_to :geometry, as: :segment

        # @return [AIXM::XY] center point
        attr_reader :center_xy

        # @return [AIXM::D] circle radius
        attr_reader :radius

        def initialize(center_xy:, radius:)
          self.center_xy, self.radius = center_xy, radius
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} center_xy="#{center_xy}" radius="#{radius.to_s}">)
        end

        def center_xy=(value)
          fail(ArgumentError, "invalid center xy") unless value.is_a? AIXM::XY
          @center_xy = value
        end

        def radius=(value)
          fail(ArgumentError, "invalid radius") unless value.is_a?(AIXM::D) && value.dist > 0
          @radius = value
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType('CWA')
            avx.geoLat(north_xy.lat(AIXM.schema))
            avx.geoLong(north_xy.long(AIXM.schema))
            avx.codeDatum('WGE')
            avx.geoLatArc(center_xy.lat(AIXM.schema))
            avx.geoLongArc(center_xy.long(AIXM.schema))
          end
        end

        private

        # Coordinates of the point which is both strictly north of the center
        # and on the circumference of the circle.
        def north_xy
          AIXM.xy(
            lat: center_xy.lat + radius.to_km.dist / (AIXM::XY::EARTH_RADIUS / 1000) * 180 / Math::PI,
            long: center_xy.long
          )
        end
      end

    end
  end
end
