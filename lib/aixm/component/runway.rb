using AIXM::Refinements

module AIXM
  module Component

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
    #   runway.length = AIXM.d or nil   # must use same unit as width
    #   runway.width = AIXM.d or nil    # must use same unit as length
    #   runway.surface = AIXM.surface
    #   runway.status = STATUSES or nil
    #   runway.remarks = String or nil
    #   runway.forth.name = AIXM.a[precision=2]   # preset based on the runway name
    #   runway.forth.geographic_orientation = AIXM.a[precision=3] or nil
    #   runway.forth.xy = AIXM.xy
    #   runway.forth.z = AIXM.z or nil
    #   runway.forth.displaced_threshold = AIXM.xy or AIXM.d or nil
    #   runway.forth.vfr_pattern = VFR_PATTERNS or nil
    #   runway.forth.remarks = String or nil
    #
    # @example Bidirectional runway
    #   runway = AIXM.runway(name: '16L/34R')
    #   runway.name   # => '16L/34R'
    #   runway.forth.name.to_s = '16L'
    #   runway.forth.geographic_orientation = 165
    #   runway.back.name.to_s = '34R'
    #   runway.back.geographic_orientation = 345
    #
    # @example Unidirectional runway:
    #   runway = AIXM.runway(name: '16L')
    #   runway.name   # => '16L'
    #   runway.forth.name.to_s = '16L'
    #   runway.forth.geographic_orientation = 165
    #   runway.back = nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rwy-runway
    class Runway
      include AIXM::Association
      include AIXM::Memoize

      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,          # e.g. construction work
        PARKED: :parked_aircraft,        # parked or disabled aircraft on helipad
        FAILAID: :visual_aids_failure,   # failure or irregular operation of visual aids
        SPOWER: :secondary_power,        # secondary power supply in operation
        OTHER: :other                    # specify in remarks
      }

      # @!method forth
      #   @return [AIXM::Component::Runway::Direction] main direction
      # @!method forth=(forth)
      #   @param forth [AIXM::Component::Runway::Direction]
      has_one :forth, accept: 'AIXM::Component::Runway::Direction'

      # @!method back
      #   @return [AIXM::Component::Runway::Direction, nil] reverse direction
      # @!method back=(back)
      #   @param back [AIXM::Component::Runway::Direction, nil]
      has_one :back, accept: 'AIXM::Component::Runway::Direction', allow_nil: true

      # @!method airport
      #   @return [AIXM::Feature::Airport] airport the runway belongs to
      belongs_to :airport

      # @return [String] full name of runway (e.g. "12/30" or "16L/34R")
      attr_reader :name

      # @return [AIXM::D, nil] length
      attr_reader :length

      # @return [AIXM::D, nil] width
      attr_reader :width

      # @return [AIXM::Component::Surface] surface of the runway
      attr_reader :surface

      # @return [Symbol, nil] status of the runway (see {STATUSES}) or +nil+ for normal operation
      attr_reader :status

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(name:)
        self.name = name
        @name.split("/").tap do |forth_name, back_name|
          self.forth = Direction.new(name: AIXM.a(forth_name))
          self.back = Direction.new(name: AIXM.a(back_name)) if back_name
          fail(ArgumentError, "invalid name") unless !back || back.name.inverse_of?(@forth.name)
        end
        @surface = AIXM.surface
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} airport=#{airport&.id.inspect} name=#{name.inspect}>)
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def length=(value)
        @length = if value
          fail(ArgumentError, "invalid length") unless value.is_a?(AIXM::D) && value.dist > 0
          fail(ArgumentError, "invalid length unit") if width && width.unit != value.unit
          @length = value
        end
      end

      def width=(value)
        @width = if value
          fail(ArgumentError, "invalid width") unless value.is_a?(AIXM::D)  && value.dist > 0
          fail(ArgumentError, "invalid width unit") if length && length.unit != value.unit
          @width = value
        end
      end

      def status=(value)
        @status = value.nil? ? nil : (STATUSES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid status"))
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.RwyUid do |rwy_uid|
          rwy_uid << airport.to_uid.indent(2)
          rwy_uid.txtDesig(name)
        end
      end
      memoize :to_uid

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Rwy do |rwy|
          rwy << to_uid.indent(2)
          rwy.valLen(length.dist.trim) if length
          rwy.valWid(width.dist.trim) if width
          rwy.uomDimRwy(length.unit.to_s.upcase) if length
          rwy.uomDimRwy(width.unit.to_s.upcase) if width && !length
          unless  (xml = surface.to_xml).empty?
            rwy << xml.indent(2)
          end
          rwy.codeSts(STATUSES.key(status).to_s) if status
          rwy.txtRmk(remarks) if remarks
        end
        %i(@forth @back).each do |direction|
          if direction = instance_variable_get(direction)
            builder << direction.to_xml
          end
        end
        builder.target!
      end

      # Runway directions further describe each direction {#forth} and {#back}
      # of a runway.
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rdn-runway-direction
      class Direction
        include AIXM::Association
        include AIXM::Memoize

        VFR_PATTERNS = {
          L: :left,
          R: :right,
          E: :left_or_right
        }

        # @!method lightings
        #   @return [Array<AIXM::Component::Lighting>] installed lighting systems
        # @!method add_lighting(lighting)
        #   @param lighting [AIXM::Component::Lighting]
        #   @return [self]
        has_many :lightings, as: :lightable

        # @!method runway
        #   @return [AIXM::Component::Runway] runway the runway direction is further describing
        belongs_to :runway, readonly: true

        # @return [AIXM::A] partial name of runway (e.g. "12" or "16L")
        attr_reader :name

        # @return [AIXM::A, nil] geographic orientation (true bearing) in degrees
        attr_reader :geographic_orientation

        # @return [AIXM::XY] beginning point (middle of the runway width)
        attr_reader :xy

        # @return [AIXM::Z, nil] elevation of the touch down zone in +qnh+
        attr_reader :z

        # @return [AIXM::XY, AIXM::D, nil] displaced threshold point either as
        #   coordinates (AIXM::XY) or distance (AIXM::D) from the beginning
        #   point
        attr_reader :displaced_threshold

        # @return [Symbol, nil] direction of the VFR flight pattern (see {VFR_PATTERNS})
        attr_reader :vfr_pattern

        # @return [String, nil] free text remarks
        attr_reader :remarks

        def initialize(name:)
          self.name = name
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} airport=#{runway&.airport&.id.inspect} name=#{name.inspect}>)
        end

        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? AIXM::A
          @name = value
        end

        def geographic_orientation=(value)
          return @geographic_orientation = nil if value.nil?
          fail(ArgumentError, "invalid geographic orientation") unless value.is_a? AIXM::A
          @geographic_orientation = value
        end

        def xy=(value)
          fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
          @xy = value
        end

        def z=(value)
          fail(ArgumentError, "invalid z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
          @z = value
        end

        def displaced_threshold=(value)
          case value
          when AIXM::XY
            @displaced_threshold = @xy.distance(value)
          when AIXM::D
            fail(ArgumentError, "invalid displaced threshold") unless value.dist > 0
            @displaced_threshold = value
          when NilClass
            @displaced_threshold = nil
          else
            fail(ArgumentError, "invalid displaced threshold")
          end
        end

        def vfr_pattern=(value)
          @vfr_pattern = value.nil? ? nil : (VFR_PATTERNS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid VFR pattern"))
        end

        def remarks=(value)
          @remarks = value&.to_s
        end

        # @return [AIXM::A] magnetic orientation (magnetic bearing) in degrees
        def magnetic_orientation
          if geographic_orientation && runway.airport.declination
            geographic_orientation - runway.airport.declination
          end
        end

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.RdnUid do |rdn_uid|
            rdn_uid << runway.to_uid.indent(2)
            rdn_uid.txtDesig(name)
          end
        end
        memoize :to_uid

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Rdn do |rdn|
            rdn << to_uid.indent(2)
            rdn.geoLat(xy.lat(AIXM.schema))
            rdn.geoLong(xy.long(AIXM.schema))
            rdn.valTrueBrg(geographic_orientation) if geographic_orientation
            rdn.valMagBrg(magnetic_orientation) if magnetic_orientation
            if z
              rdn.valElevTdz(z.alt)
              rdn.uomElevTdz(z.unit.upcase.to_s)
            end
            rdn.codeVfrPattern(VFR_PATTERNS.key(vfr_pattern).to_s) if vfr_pattern
            rdn.txtRmk(remarks) if remarks
          end
          if displaced_threshold
            builder.Rdd do |rdd|
              rdd.RddUid do |rdd_uid|
                rdd_uid << to_uid.indent(4)
                rdd_uid.codeType('DPLM')
                rdd_uid.codeDayPeriod('A')
              end
              rdd.valDist(displaced_threshold.dist.trim)
              rdd.uomDist(displaced_threshold.unit.to_s.upcase)
              rdd.txtRmk(remarks) if remarks
            end
          end
          lightings.each do |lighting|
            builder << lighting.to_xml(as: :Rls)
          end
          builder.target!
        end
      end
    end
  end
end
