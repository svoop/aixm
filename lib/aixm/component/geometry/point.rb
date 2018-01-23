module AIXM
  module Component
    class Geometry

      ##
      # Points are defined by +xy+ coordinates.
      class Point
        extend Forwardable
        using AIXM::Refinements

        def_delegators :xy, :to_digest

        attr_reader :xy

        def initialize(xy:)
          fail(ArgumentError, "invalid xy") unless xy.is_a? AIXM::XY
          @xy = xy
        end

        ##
        # Render AIXM
        def to_xml(*extensions)
          format = extensions >> :OFM ? :OFM : :AIXM
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType('GRC')
            avx.geoLat(xy.lat(format))
            avx.geoLong(xy.long(format))
            avx.codeDatum('WGE')
          end
        end
      end

    end
  end
end
