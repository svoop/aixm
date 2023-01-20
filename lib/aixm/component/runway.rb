using AIXM::Refinements

module AIXM
  class Component

    # Runways are landing and takeoff strips for forward propelled aircraft.
    #
    # By convention, the runway name is usually the composition of the runway
    # forth name (smaller number) and the runway back name (bigger number)
    # joined with a forward slash e.g. "12/30" or "16R/34L".
    #
    # A runway has one or to directions accessible as +runway.forth+ (mandatory)
    # and +runway.back+ (optional). Both have identical properties.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   runway = AIXM.runway(
    #     name: String
    #   )
    #   runway.dimensions = AIXM.r or nil
    #   runway.surface = AIXM.surface
    #   runway.marking = String or nil
    #   runway.status = STATUSES or nil
    #   runway.remarks = String or nil
    #   runway.forth.name = AIXM.a   # preset based on the runway name
    #   runway.forth.geographic_bearing = AIXM.a or nil
    #   runway.forth.xy = AIXM.xy   # center point at beginning edge of runway
    #   runway.forth.z = AIXM.z or nil   # center point at beginning edge of runway
    #   runway.forth.touch_down_zone_z = AIXM.z or nil
    #   runway.forth.displaced_threshold = AIXM.d or nil       # sets displaced_threshold_xy as well
    #   runway.forth.displaced_threshold_xy = AIXM.xy or nil   # sets displaced_threshold as well
    #   runway.forth.vasis = AIXM.vasis or nil (default: unspecified VASIS)
    #   runway.forth.add_lighting = AIXM.lighting
    #   runway.forth.add_approach_lighting = AIXM.approach_lighting
    #   runway.forth.vfr_pattern = VFR_PATTERNS or nil
    #   runway.forth.remarks = String or nil
    #
    # @example Bidirectional runway
    #   runway = AIXM.runway(name: '16L/34R')
    #   runway.name   # => '16L/34R'
    #   runway.forth.name.to_s = '16L'
    #   runway.forth.geographic_bearing = 165
    #   runway.back.name.to_s = '34R'
    #   runway.back.geographic_bearing = 345
    #
    # @example Unidirectional runway:
    #   runway = AIXM.runway(name: '16L')
    #   runway.name   # => '16L'
    #   runway.forth.name.to_s = '16L'
    #   runway.forth.geographic_bearing = 165
    #   runway.back = nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rwy-runway
    class Runway < Component
      include AIXM::Concerns::Association
      include AIXM::Concerns::Marking
      include AIXM::Concerns::Remarks

      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,          # e.g. construction work
        PARKED: :parked_aircraft,        # parked or disabled aircraft on helipad
        FAILAID: :visual_aids_failure,   # failure or irregular operation of visual aids
        SPOWER: :secondary_power,        # secondary power supply in operation
        OTHER: :other                    # specify in remarks
      }.freeze

      # @!method forth
      #   @return [AIXM::Component::Runway::Direction] main direction
      #
      # @!method forth=(forth)
      #   @param forth [AIXM::Component::Runway::Direction]
      has_one :forth, accept: 'AIXM::Component::Runway::Direction'

      # @!method back
      #   @return [AIXM::Component::Runway::Direction, nil] reverse direction
      #
      # @!method back=(back)
      #   @param back [AIXM::Component::Runway::Direction, nil]
      has_one :back, accept: 'AIXM::Component::Runway::Direction', allow_nil: true

      # @!method surface
      #   @return [AIXM::Component::Surface] surface of the runway
      #
      # @!method surface=(surface)
      #   @param surface [AIXM::Component::Surface]
      has_one :surface, accept: 'AIXM::Component::Surface'

      # @!method airport
      #   @return [AIXM::Feature::Airport] airport the runway belongs to
      belongs_to :airport

      # Full name of runway (e.g. "12/30" or "16L/34R")
      #
      # @overload name
      #   @return [String]
      # @overload name=(value)
      #   @param value [String]
      attr_reader :name

      # Dimensions
      #
      # @overload dimensions
      #   @return [AIXM::R, nil]
      # @overload dimensions=(value)
      #   @param value [AIXM::R, nil]
      attr_reader :dimensions

      # Status of the runway
      #
      # @overload status
      #   @return [Symbol, nil] any of {STATUSES} or +nil+ for normal operation
      # @overload status=(value)
      #   @param value [Symbol, nil] any of {STATUSES} or +nil+ for normal
      #     operation
      attr_reader :status

      # See the {cheat sheet}[AIXM::Component::Runway] for examples on how to
      # create instances of this class.
      def initialize(name:)
        self.name = name
        @name.split("/").tap do |forth_name, back_name|
          self.forth = Direction.new(name: AIXM.a(forth_name))
          self.back = Direction.new(name: AIXM.a(back_name)) if back_name
          fail(ArgumentError, "invalid name") unless !back || back.name.inverse_of?(@forth.name)
        end
        self.surface = AIXM.surface
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} airport=#{airport&.id.inspect} name=#{name.inspect}>)
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def dimensions=(value)
        fail(ArgumentError, "invalid dimensions") unless value.nil? || value.is_a?(AIXM::R)
        @dimensions = value
      end

      def status=(value)
        @status = value.nil? ? nil : (STATUSES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid status"))
      end

      # Center line of the runway
      #
      # The center line of unidirectional runwawys is calculated using the
      # runway dimensions. If they are unknown, the calculation is not possible
      # and this method returns +nil+.
      #
      # @return [AIXM::L, nil]
      def center_line
        if back || dimensions
          AIXM.l.add_line_point(
            xy: forth.xy,
            z: forth.z
          ).add_line_point(
            xy: (back&.xy || forth.xy.add_distance(dimensions.length, forth.geographic_bearing)),
            z: back&.z
          )
        end
      end

      # @!visibility private
      def add_uid_to(builder)
        builder.RwyUid do |rwy_uid|
          airport.add_uid_to(rwy_uid)
          rwy_uid.txtDesig(name)
        end
      end

      # @!visibility private
      def add_to(builder)
        builder.Rwy do |rwy|
          add_uid_to(rwy)
          if dimensions
            rwy.valLen(dimensions.length.to_m.dim.trim)
            rwy.valWid(dimensions.width.to_m.dim.trim)
            rwy.uomDimRwy('M')
          end
          surface.add_to(rwy) if surface
          rwy.codeSts(STATUSES.key(status)) if status
          rwy.txtMarking(marking) if marking
          rwy.txtRmk(remarks) if remarks
        end
        center_line.line_points.each do |line_point|
          builder.Rcp do |rcp|
            rcp.RcpUid do |rcp_uid|
              add_uid_to(rcp)
              rcp.geoLat(line_point.xy.lat(AIXM.schema))
              rcp.geoLong(line_point.xy.long(AIXM.schema))
            end
            rcp.codeDatum('WGE')
            if line_point.z
              rcp.valElev(line_point.z.alt)
              rcp.uomDistVer(line_point.z.unit.upcase)
            end
          end
        end
        %i(@forth @back).each do |direction|
          if direction = instance_variable_get(direction)
            direction.add_to(builder)
          end
        end
      end

      # Runway directions further describe each direction {#forth} and {#back}
      # of a runway.
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rdn-runway-direction
      class Direction
        include AIXM::Concerns::Association
        include AIXM::Concerns::Memoize
        include AIXM::Concerns::XMLBuilder
        include AIXM::Concerns::Remarks

        VFR_PATTERNS = {
          L: :left,
          R: :right,
          E: :left_or_right
        }.freeze

        # @!method lightings
        #   @return [Array<AIXM::Component::Lighting>] installed lighting systems
        #
        # @!method add_lighting(lighting)
        #   @param lighting [AIXM::Component::Lighting]
        #   @return [self]
        has_many :lightings, as: :lightable

        # @!method approach_lightings
        #   @return [Array<AIXM::Component::ApproachLighting>] installed approach
        #     lighting systems
        #
        # @!method add_approach_lighting(approach_lighting)
        #   @param approach_lighting [AIXM::Component::ApproachLighting]
        #   @return [self]
        has_many :approach_lightings, as: :approach_lightable

        # @!method runway
        #   @return [AIXM::Component::Runway] runway the runway direction is
        #     further describing
        belongs_to :runway, readonly: true

        # Partial name of runway (e.g. "12" or "16L")
        #
        # @overload name
        #   @return [AIXM::A]
        # @overload name=(value)
        #   @param value [AIXM::A]
        attr_reader :name

        # @return [AIXM::A, nil] (true) geographic bearing in degrees
        attr_reader :geographic_bearing

        # @return [AIXM::XY] center point at the beginning edge of the runway
        attr_reader :xy

        # @return [AIXM::Z, nil] elevation of the center point at the beginning
        #   edge of the runway in +qnh+
        attr_reader :z

        # @return [AIXM::Z, nil] elevation of the touch down zone in +qnh+
        attr_reader :touch_down_zone_z

        # @return [AIXM::D, nil] displaced threshold distance from edge of runway
        attr_reader :displaced_threshold

        # @return [AIXM::XY, nil] displaced threshold point
        attr_reader :displaced_threshold_xy

        # @return [AIXM::Component::VASIS, nil] visual approach slope indicator
        #   system
        attr_reader :vasis

        # @return [Symbol, nil] direction of the VFR flight pattern (see {VFR_PATTERNS})
        attr_reader :vfr_pattern

        # See the {cheat sheet}[AIXM::Component::Runway] for examples on how to
        #   create instances of this class.
        def initialize(name:)
          self.name = name
          self.vasis = AIXM.vasis
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} airport=#{runway&.airport&.id.inspect} name=#{name.to_s(:runway).inspect}>)
        end

        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? AIXM::A
          @name = value
        end

        def geographic_bearing=(value)
          return @geographic_bearing = nil if value.nil?
          fail(ArgumentError, "invalid geographic bearing") unless value.is_a? AIXM::A
          @geographic_bearing = value
        end

        def xy=(value)
          fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
          @xy = value
        end

        def z=(value)
          fail(ArgumentError, "invalid z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
          @z = value
        end

        def touch_down_zone_z=(value)
          fail(ArgumentError, "invalid touch_down_zone_z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
          @touch_down_zone_z = value
        end

        def displaced_threshold=(value)
          if value
            fail(ArgumentError, "invalid displaced threshold") unless value.is_a?(AIXM::D) && value.dim > 0
            fail(RuntimeError, "xy required to calculate displaced threshold xy") unless xy
            fail(RuntimeError, "geographic bearing required to calculate displaced threshold xy") unless geographic_bearing
            @displaced_threshold = value
            @displaced_threshold_xy = xy.add_distance(value, geographic_bearing)
          else
            @displaced_threshold = @displaced_threshold_xy = nil
          end
        end

        def displaced_threshold_xy=(value)
          if value
            fail(ArgumentError, "invalid displaced threshold xy") unless value.is_a? AIXM::XY
            fail(RuntimeError, "xy required to calculate displaced threshold") unless xy
            @displaced_threshold_xy = value
            @displaced_threshold = xy.distance(value)
          else
            @displaced_threshold = @displaced_threshold_xy = nil
          end
        end

        def vasis=(value)
          fail(ArgumentError, "invalid vasis") unless value.nil? || value.is_a?(AIXM::Component::VASIS)
          @vasis = value
        end

        def vfr_pattern=(value)
          @vfr_pattern = value.nil? ? nil : (VFR_PATTERNS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid VFR pattern"))
        end

        # @return [AIXM::A] magnetic bearing in degrees
        def magnetic_bearing
          if geographic_bearing && runway.airport.declination
            geographic_bearing - runway.airport.declination
          end
        end

        # @return [AIXM::XY] displaced threshold if any or edge of runway otherwise
        def threshold_xy
          displaced_threshold_xy || xy
        end

        # @!visibility private
        def add_uid_to(builder)
          builder.RdnUid do |rdn_uid|
            runway.add_uid_to(rdn_uid)
            rdn_uid.txtDesig(name.to_s(:runway))
          end
        end

        # @!visibility private
        def add_to(builder)
          builder.Rdn do |rdn|
            add_uid_to(rdn)
            rdn.geoLat(threshold_xy.lat(AIXM.schema))
            rdn.geoLong(threshold_xy.long(AIXM.schema))
            rdn.valTrueBrg(geographic_bearing.to_s(:bearing)) if geographic_bearing
            rdn.valMagBrg(magnetic_bearing.to_s(:bearing)) if magnetic_bearing
            if touch_down_zone_z
              rdn.valElevTdz(touch_down_zone_z.alt)
              rdn.uomElevTdz(touch_down_zone_z.unit.upcase)
            end
            vasis.add_to(rdn) if vasis
            rdn.codeVfrPattern(VFR_PATTERNS.key(vfr_pattern)) if vfr_pattern
            rdn.txtRmk(remarks) if remarks
          end
          if displaced_threshold
            builder.Rdd do |rdd|
              rdd.RddUid do |rdd_uid|
                add_uid_to(rdd_uid)
                rdd_uid.codeType('DPLM')
                rdd_uid.codeDayPeriod('A')
              end
              rdd.valDist(displaced_threshold.dim.trim)
              rdd.uomDist(displaced_threshold.unit.upcase)
              rdd.txtRmk(remarks) if remarks
            end
          end
          lightings.each do |lighting|
            lighting.add_to(builder, as: :Rls)
          end
          approach_lightings.each do |approach_lighting|
            approach_lighting.add_to(builder, as: :Rda)
          end
        end
      end
    end
  end
end
