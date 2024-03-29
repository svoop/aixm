using AIXM::Refinements

module AIXM
  class Component
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

        # Center point
        #
        # @overload center_xy
        #   @return [AIXM::XY]
        # @overload center_xy=(value)
        #   @param value [AIXM::XY]
        attr_reader :center_xy

        # See the {cheat sheet}[AIXM::Component::Geometry::Arc] for examples on
        # how to create instances of this class.
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

        # Whether the arc is going clockwise
        #
        # @!attribute clockwise
        # @overload clockwise?
        #   @return [Boolean] clockwise (true) or counterclockwise (false)
        # @overload clockwise=(value)
        #   @param value [Boolean] clockwise (true) or counterclockwise (false)
        def clockwise?
          @clockwise
        end

        def clockwise=(value)
          fail(ArgumentError, "clockwise must be true or false") unless [true, false].include? value
          @clockwise = value
        end

        # @!visibility private
        def add_to(builder)
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
