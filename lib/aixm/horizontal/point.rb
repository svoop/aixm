module AIXM
  module Horizontal
    class Point

      attr_reader :xy

      ##
      # Defines a point +xy+
      def initialize(xy:)
        fail(ArgumentError, "invalid xy") unless xy.is_a? AIXM::XY
        @xy = xy
      end

      def to_xml
        builder = Builder::XmlMarkup.new
        builder.Avx do |avx|
          avx.codeType('GRC')
          avx.geoLat(xy.lat(:AIXM))
          avx.geoLong(xy.long(:AIXM))
        end
      end

    end
  end
end
