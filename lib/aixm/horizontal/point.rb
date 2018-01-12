module AIXM
  module Horizontal
    class Point

      using AIXM::Refinements

      attr_reader :xy

      ##
      # Defines a point +xy+
      def initialize(xy:)
        fail(ArgumentError, "invalid xy") unless xy.is_a? AIXM::XY
        @xy = xy
      end

      ##
      # Digest to identify the payload
      def to_digest
        [xy.lat, xy.long].to_digest
      end

      def to_xml(*extensions)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Avx do |avx|
          avx.codeType('GRC')
          avx.geoLat(xy.lat(:AIXM))
          avx.geoLong(xy.long(:AIXM))
        end
      end

    end
  end
end
