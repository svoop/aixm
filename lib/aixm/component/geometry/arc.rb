module AIXM
  module Component
    class Geometry

      ##
      # Arcs are +clockwise+ (true/false) circle sectors around +center_xy+ and
      # starting at +xy+.
      class Arc < Point
        using AIXM::Refinements

        attr_reader :center_xy

        def initialize(xy:, center_xy:, clockwise:)
          super(xy: xy)
          fail(ArgumentError, "invalid center xy") unless center_xy.is_a? AIXM::XY
          fail(ArgumentError, "clockwise must be true or false") unless [true, false].include? clockwise
          @center_xy, @clockwise = center_xy, clockwise
        end

        ##
        # Whether the arc is going clockwise (true) or not (false)
        def clockwise?
          @clockwise
        end

        ##
        # Digest to identify the payload
        def to_digest
          [xy.lat, xy.long, center_xy.lat, center_xy.long, clockwise?].to_digest
        end

        ##
        # Render XML
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType(clockwise? ? 'CWA' : 'CCA')
            avx.geoLat(xy.lat(AIXM.format))
            avx.geoLong(xy.long(AIXM.format))
            avx.codeDatum('WGE')
            avx.geoLatArc(center_xy.lat(AIXM.format))
            avx.geoLongArc(center_xy.long(AIXM.format))
          end
        end
      end

    end
  end
end
