module AIXM
  module Component
    class Geometry

      ##
      # Circles are defined by a +center_xy+ and a +radius+ in kilometers.
      class Circle < Base
        using AIXM::Refinements

        attr_reader :center_xy, :radius

        def initialize(center_xy:, radius:)
          fail(ArgumentError, "invalid center xy") unless center_xy.is_a? AIXM::XY
          @center_xy, @radius = center_xy, radius
        end

        ##
        # Digest to identify the payload
        def to_digest
          [center_xy.lat, center_xy.long, radius].to_digest
        end

        ##
        # Render AIXM markup
        def to_aixm(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType('CWA')
            avx.geoLat(north_xy.lat(format_for(*extensions)))
            avx.geoLong(north_xy.long(format_for(*extensions)))
            avx.codeDatum('WGE')
            avx.geoLatArc(center_xy.lat(format_for(*extensions)))
            avx.geoLongArc(center_xy.long(format_for(*extensions)))
          end
        end

        private

        ##
        # Coordinates of the point which is both strictly north of the center
        # and on the circumference of the circle
        def north_xy
          AIXM.xy(
            lat: center_xy.lat + radius.to_f / (AIXM::EARTH_RADIUS / 1000) * 180 / Math::PI,
            long: center_xy.long
          )
        end
      end

    end
  end
end
