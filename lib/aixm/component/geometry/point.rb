module AIXM
  module Component
    class Geometry

      ##
      # Points are defined by +xy+ coordinates.
      class Point < Base
        extend Forwardable
        using AIXM::Refinements

        def_delegators :xy, :to_digest

        attr_reader :xy

        def initialize(xy:)
          fail(ArgumentError, "invalid xy") unless xy.is_a? AIXM::XY
          @xy = xy
        end

        ##
        # Render XML
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType('GRC')
            avx.geoLat(xy.lat(AIXM.format))
            avx.geoLong(xy.long(AIXM.format))
            avx.codeDatum('WGE')
          end
        end
      end

    end
  end
end
