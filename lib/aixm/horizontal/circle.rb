module AIXM
  module Horizontal
    class Circle

      using AIXM::Refinements

      attr_reader :center_xy, :radius

      ##
      # Defines a circle around +center_xy+ with a +radius+ in kilometers
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
      # Render AIXM
      #
      # Extensions:
      # * +:OFM+ - Open Flightmaps
      def to_xml(*extensions)
        format = extensions.include?(:OFM) ? :OFM : :AIXM
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Avx do |avx|
          avx.codeType('CWA')
          avx.geoLat(north_xy.lat(format))
          avx.geoLong(north_xy.long(format))
          avx.codeDatum('WGE')
          avx.geoLatArc(center_xy.lat(format))
          avx.geoLongArc(center_xy.long(format))
        end
      end

      private

      ##
      # Coordinates of the point which is both strictly north of the center
      # and on the circumference of the circle
      def north_xy
        AIXM::XY.new(
          lat: center_xy.lat + radius.to_f / 6371 * 180 / Math::PI,
          long: center_xy.long
        )
      end

    end
  end
end
