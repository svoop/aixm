using AIXM::Refinements

module AIXM
  class Component
    class Geometry

      # Points are defined by {#xy} coordinates.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   point = AIXM.point(
      #     xy: AIXM.xy
      #   )
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Airspace#point
      class Point
        extend Forwardable

        def_delegators :xy

        # @return [AIXM::XY] (starting) point
        attr_reader :xy

        def initialize(xy:)
          self.xy = xy
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} xy="#{xy.to_s}">)
        end

        def xy=(value)
          fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
          @xy = value
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType('GRC')
            avx.geoLat(xy.lat(AIXM.schema))
            avx.geoLong(xy.long(AIXM.schema))
            avx.codeDatum('WGE')
          end
        end
      end

    end
  end
end
