module AIXM
  module Horizontal
    class Arc < Point

      using AIXM::Refinements

      attr_reader :center_xy

      ##
      # Defines a +clockwise+ (true/false) arc around +center_xy+ and starting
      # at +xy+
      def initialize(xy:, center_xy:, clockwise:)
        super(xy: xy)
        fail(ArgumentError, "invalid center xy") unless center_xy.is_a? AIXM::XY
        fail(ArgumentError, "clockwise must be true or false") unless [true, false].include? clockwise
        @center_xy, @clockwise = center_xy, clockwise
      end

      def clockwise?
        @clockwise
      end

      ##
      # Digest to identify the payload
      def to_digest
        [xy.lat, xy.long, center_xy.lat, center_xy.long, clockwise?].to_digest
      end

      def to_xml(*extensions)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Avx do |avx|
          avx.codeType(clockwise? ? 'CWA' : 'CCA')
          avx.geoLat(xy.lat(:AIXM))
          avx.geoLong(xy.long(:AIXM))
          avx.codeDatum('WGE')
          avx.geoLatArc(center_xy.lat(:AIXM))
          avx.geoLongArc(center_xy.long(:AIXM))
        end
      end

    end
  end
end
