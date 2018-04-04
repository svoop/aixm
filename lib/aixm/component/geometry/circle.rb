using AIXM::Refinements

module AIXM
  module Component
    class Geometry

      ##
      # Circles are defined by a +center_xy+ and a +radius+ in kilometers.
      class Circle
        attr_reader :center_xy, :radius

        def initialize(center_xy:, radius:)
          self.center_xy, self.radius = center_xy, radius
        end

        def center_xy=(value)
          fail(ArgumentError, "invalid center xy") unless value.is_a? AIXM::XY
          @center_xy = value
        end

        def radius=(value)
          fail(ArgumentError, "invalid radius") unless value.is_a?(Numeric) && value > 0
          @radius = value.to_f
        end

        def inspect
          %Q(#<#{self.class} xy="#{xy.to_s}">)
        end

        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType('CWA')
            avx.geoLat(north_xy.lat(AIXM.format))
            avx.geoLong(north_xy.long(AIXM.format))
            avx.codeDatum('WGE')
            avx.geoLatArc(center_xy.lat(AIXM.format))
            avx.geoLongArc(center_xy.long(AIXM.format))
          end
        end

        private

        ##
        # Coordinates of the point which is both strictly north of the center
        # and on the circumference of the circle
        def north_xy
          AIXM.xy(
            lat: center_xy.lat + radius.to_f / (AIXM::XY::EARTH_RADIUS / 1000) * 180 / Math::PI,
            long: center_xy.long
          )
        end
      end

    end
  end
end
