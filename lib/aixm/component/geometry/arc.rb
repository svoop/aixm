using AIXM::Refinements

module AIXM
  module Component
    class Geometry

      # Arcs are clockwise or counter clockwise circle segments around a
      # {#center_xy} and starting at {#xy}.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   arc = AIXM.arc(
      #     xy: AIXM.xy
      #     center_xy: AIXM.xy
      #     clockwise: true or false
      #   )
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airspace#arc
      class Arc < Point
        # @return [AIXM::XY] center point
        attr_reader :center_xy

        def initialize(xy:, center_xy:, clockwise:)
          super(xy: xy)
          self.center_xy, self.clockwise = center_xy, clockwise
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} xy="#{xy}" center_xy="#{center_xy}" clockwise=#{clockwise}>)
        end

        def center_xy=(value)
          fail(ArgumentError, "invalid center xy") unless value.is_a? AIXM::XY
          @center_xy = value
        end

        # @!attribute [w] clockwise
        # @return [Boolean] wheter the arc is going clockwise (true) or not (false)
        def clockwise?
          @clockwise
        end

        def clockwise=(value)
          fail(ArgumentError, "clockwise must be true or false") unless [true, false].include? value
          @clockwise = value
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType(clockwise? ? 'CWA' : 'CCA')
            avx.geoLat(xy.lat(AIXM.schema))
            avx.geoLong(xy.long(AIXM.schema))
            avx.codeDatum('WGE')
            avx.geoLatArc(center_xy.lat(AIXM.schema))
            avx.geoLongArc(center_xy.long(AIXM.schema))
          end
        end
      end

    end
  end
end
