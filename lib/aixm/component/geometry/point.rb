using AIXM::Refinements

module AIXM
  module Component
    class Geometry

      ##
      # Points are defined by +xy+ coordinates.
      class Point
        extend Forwardable

        def_delegators :xy

        attr_reader :xy

        def initialize(xy:)
          self.xy = xy
        end

        def inspect
          %Q(#<#{self.class} xy="#{xy.to_s}">)
        end

        def xy=(value)
          fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
          @xy = value
        end

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
