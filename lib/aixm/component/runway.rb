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
    #   runway.length = Integer or nil   # meters
    #   runway.width = Integer or nil    # meters
    #   runway.composition = COMPOSITIONS or nil
    #   runway.status = STATUSES or nil
    #   runway.remarks = String or nil
    #   runway.forth.name = String   # preset based on the runway name
    #   runway.forth.geographic_orientation = Integer or nil   # degrees
    #   runway.forth.xy = AIXM.xy
    #   runway.forth.z = AIXM.z or nil
    #   runway.forth.displaced_threshold = Integer or nil   # meters
    #   runway.forth.remarks = String or nil
    #
    # @example Bidirectional runway
    #   runway = AIXM.runway(name: '16L/34R')
    #   runway.name   # => '16L/34R'
    #   runway.forth.name = '16L'
    #   runway.forth.geographic_orientation = 165
    #   runway.back.name = '34R'
    #   runway.back.geographic_orientation = 345
    #
    # @example Unidirectional runway:
    #   runway = AIXM.runway(name: '16L')
    #   runway.name   # => '16L'
    #   runway.forth.name = '16L'
    #   runway.forth.geographic_orientation = 165
    #   runway.back = nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airport#rwy-runway
    class Runway
      COMPOSITIONS = {
        ASPH: :asphalt,
        BITUM: :bitumen,        # dug up, bound and rolled ground
        CONC: :concrete,
        GRAVE: :gravel,         # small and midsize rounded stones
        MACADAM: :macadam,      # small rounded stones
        SAND: :sand,
        GRADE: :graded_earth,   # graded or rolled earth possibly with some grass
        GRASS: :grass,          # lawn
        WATER: :water,
        OTHER: :other           # specify in remarks
      }

      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,          # e.g. construction work
        PARKED: :parked_aircraft,        # parked or disabled aircraft on helipad
        FAILAID: :visual_aids_failure,   # failure or irregular operation of visual aids
        SPOWER: :secondary_power,        # secondary power supply in operation
        OTHER: :other                    # specify in remarks
      }

      # @return [AIXM::Feature::Airport] airport the runway belongs to
      attr_reader :airport

      # @return [String] full name of runway (e.g. "12/30" or "16L/34R")
      attr_reader :name

      # @return [Integer, nil] length in meters
      attr_reader :length

      # @return [Integer, nil] width in meters
      attr_reader :width

      # @return [Symbol, nil] composition of the surface (see {COMPOSITIONS})
      attr_reader :composition

      # @return [Symbol, nil] status of the runway (see {STATUSES}) or +nil+ for normal operation
      attr_reader :status

      # @return [String, nil] free text remarks
      attr_reader :remarks

      # @return [AIXM::Component::Runway::Direction] main direction
      attr_accessor :forth

      # @return [AIXM::Component::Runway::Direction] reverse direction
      attr_accessor :back

      def initialize(name:)
        self.name = name
        @name.split('/').tap do |forth, back|
          @forth = Direction.new(runway: self, name: forth)
          @back = Direction.new(runway: self, name: back) if back
        end
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} name=#{name.inspect}>)
      end

      def airport=(value)
        fail(ArgumentError, "invalid airport") unless value.is_a? AIXM::Feature::Airport
        @airport = value
      end
      private :airport=

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def length=(value)
        fail(ArgumentError, "invalid length") unless value.nil? || (value.is_a?(Numeric) && value > 0)
        @length = value.nil? ? nil : value.to_i
      end

      def width=(value)
        fail(ArgumentError, "invalid width") unless value.nil? || (value.is_a?(Numeric)  && value > 0)
        @width = value.nil? ? nil : value.to_i
      end

      def composition=(value)
        @composition = value.nil? ? nil : COMPOSITIONS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid composition")
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

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Rwy do |rwy|
          rwy << to_uid.indent(2)
          rwy.valLen(length) if length
          rwy.valWid(width) if width
          rwy.uomDimRwy('M') if length || width
          rwy.codeComposition(COMPOSITIONS.key(composition).to_s) if composition
          rwy.codeSts(STATUSES.key(status).to_s) if status
          rwy.txtRmk(remarks) if remarks
        end
        %i(@forth @back).each do |direction|
          direction = instance_variable_get(direction)
          builder << direction.to_xml if direction
        end
        builder.target!
      end

      # Runway directions further describe each direction +forth+ and +back+
      # of a runway.
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Airport#rdn-runway-direction
      class Direction
        # @return [AIXM::Component::Runway] runway the runway direction is further describing
        attr_reader :runway

        # @return [String] partial name of runway (e.g. "12" or "16L")
        attr_reader :name

        # @return [Integer, nil] geographic orientation (true bearing) in degrees
        attr_reader :geographic_orientation

        # @return [AIXM::XY] beginning point (middle of the runway width)
        attr_reader :xy

        # @return [AIXM::Z, nil] elevation of the touch down zone in +qnh+
        attr_reader :z

        # @return [AIXM::XY, Integer, nil] displaced threshold point either as
        #   coordinates (AIXM::XY) or distance (Integer) in meters from the
        #   beginning point
        attr_reader :displaced_threshold

        # @return [String, nil] free text remarks
        attr_reader :remarks

        def initialize(runway:, name:)
          self.runway, self.name = runway, name
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} name=#{name.inspect}>)
        end

        def runway=(value)
          fail(ArgumentError, "invalid runway") unless value.is_a? AIXM::Component::Runway
          @runway = value
        end
        private :runway

        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? String
          @name = value.uptrans
        end

        def geographic_orientation=(value)
          return @geographic_orientation = nil if value.nil?
          fail(ArgumentError, "invalid geographic orientation") unless value.is_a? Numeric
          @geographic_orientation = value.to_i
          fail(ArgumentError, "invalid geographic orientation") unless (0..359).include? @geographic_orientation
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
          @displaced_threshold = case value
            when AIXM::XY then @xy.distance(value).to_i
            when Numeric then value.to_i
            when NilClass then nil
            else fail(ArgumentError, "invalid displaced threshold")
          end
        end

        def remarks=(value)
          @remarks = value&.to_s
        end

        # @return [Integer] magnetic orientation (magnetic bearing) in degrees
        def magnetic_orientation
          if geographic_orientation && runway.airport.declination
            (geographic_orientation + runway.airport.declination).round
          end
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Rdn do |rdn|
            rdn.RdnUid do |rdn_uid|
              rdn_uid << runway.to_uid.indent(4)
              rdn_uid.txtDesig(name)
            end
            rdn.geoLat(xy.lat(AIXM.schema))
            rdn.geoLong(xy.long(AIXM.schema))
            rdn.valTrueBrg(geographic_orientation) if geographic_orientation
            rdn.valMagBrg(magnetic_orientation) if magnetic_orientation
            if z
              rdn.valElevTdz(z.alt)
              rdn.uomElevTdz(z.unit.upcase.to_s)
            end
            rdn.txtRmk(remarks) if remarks
          end
          if displaced_threshold
            builder.Rdd do |rdd|
              rdd.RddUid do |rdd_uid|
                rdd_uid.RdnUid do |rdn_uid|
                  rdn_uid << runway.to_uid.indent(6)
                  rdn_uid.txtDesig(name)
                end
                rdd_uid.codeType('DPLM')
                rdd_uid.codeDayPeriod('A')
              end
              rdd.valDist(displaced_threshold)
              rdd.uomDist('M')
              rdd.txtRmk(remarks) if remarks
            end
          end
          builder.target!
        end
      end
    end
  end
end
