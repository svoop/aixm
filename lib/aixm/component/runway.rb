using AIXM::Refinements

module AIXM
  module Component

    ##
    # Runways are landing and takeoff strips
    #
    # By convention, the runway name is usually the composition of the runway
    # forth name (smaller number) and the runway back name (bigger number)
    # joined with a forward slash.
    #
    # Arguments:
    # * +name+ - name of the runway
    #
    # Example of a bidirectional runway:
    #   runway = AIXM.runway(name: '16L/34R')
    #   runway.name   # => '16L/34R'
    #   runway.forth.name = '16L'
    #   runway.forth.geographic_orientation = 165
    #   runway.back.name = '34R'
    #   runway.back.geographic_orientation = 345
    #
    # Example of a unidirectinal runway:
    #   runway = AIXM.runway(name: '16L')
    #   runway.name   # => '16L'
    #   runway.forth.name = '16L'
    #   runway.forth.geographic_orientation = 165
    #   runway.back = nil
    class Runway
      COMPOSITIONS = {
        ASPH: :asphalt,
        BITUM: :bitumen,
        CONC: :concrete,
        GRAVE: :gravel,
        MACADAM: :macadam,
        SAND: :sand,
        GRADE: :graded_earth,
        GRASS: :grass,
        WATER: :water,
        OTHER: :other
      }

      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,
        PARKED: :parked_aircraft,
        FAILAID: :visual_aids_failure,
        SPOWER: :secondary_power,
        OTHER: :other
      }

      attr_reader :airport, :name
      attr_reader :length, :width, :composition, :status, :remarks
      attr_accessor :forth, :back

      def initialize(name:)
        self.name = name
        @name.split('/').tap do |forth, back|
          @forth = Direction.new(runway: self, name: forth)
          @back = Direction.new(runway: self, name: back) if back
        end
      end

      def inspect
        %Q(#<#{self.class} name=#{name.inspect}>)
      end

      def airport=(value)
        fail(ArgumentError, "invalid airport") unless value.is_a? AIXM::Feature::Airport
        @airport = value
      end
      private :airport=

      ##
      # Name of the runway (e.g. "12/30" or "34L/16R")
      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      ##
      # Length in meters
      def length=(value)
        fail(ArgumentError, "invalid length") unless value.is_a?(Numeric) && value > 0
        @length = value.to_i
      end

      ##
      # Width in meters
      def width=(value)
        fail(ArgumentError, "invalid width") unless value.is_a?(Numeric)  && value > 0
        @width = value.to_i
      end

      ##
      # Composition of the surface
      #
      # Allowed values:
      # * +:asphalt+ (+:ASPH+)
      # * +:concrete+ (+:CONC+)
      # * +:bitumen+ (+:BITUM+) - dug up, bound and rolled ground
      # * +:gravel+ (+:GRAVE+) - small and midsize rounded stones
      # * +:macadam+ (+:MACADAM+) - small rounded stones
      # * +:sand+ (+:SAND+)
      # * +:graded_earth+ (+:GRADE+) - graded or rolled earth possibly with
      #                                some grass
      # * +:grass+ (+:GRASS+) - lawn
      # * +:water+ (+:WATER+)
      # * +:other+ (+:OTHER+) - specify in +remarks+
      def composition=(value)
        @composition = COMPOSITIONS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid composition")
      end

      ##
      # Runway status
      #
      # Allowed values:
      # * +nil+ - normal operation
      # * +:closed+ (+:CLSD+)
      # * +:work_in_progress+ (+:WIP+) - e.g. construction work
      # * +:parked_aircraft+ (+:PARKED+) - parked or disabled aircraft on runway
      # * +:visual_aids_failure+ (+:FAILAID+) - failure or irregular operation
      #                                         of visual aids
      # * +:secondary_power+ (+:SPOWER+) - secondary power supply in operation
      # * +:other+ (+:OTHER+) - specify in +remarks+
      def status=(value)
        @status = value.nil? ? nil : (STATUSES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid status"))
      end

      ##
      # Free text remarks
      def remarks=(value)
        @remarks = value&.to_s
      end

      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.RwyUid do |rwy_uid|
          rwy_uid << airport.to_uid.indent(2)
          rwy_uid.txtDesig(name)
        end
      end

      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Rwy do |rwy|
          rwy << to_uid.indent(2)
          rwy.valLen(length)
          rwy.valWid(width)
          rwy.uomDimRwy('M')
          rwy.codeComposition(COMPOSITIONS.key(composition).to_s)
          rwy.codeSts(STATUSES.key(status).to_s) if status
          rwy.txtRmk(remarks) if remarks
        end
        %i(@forth @back).each do |direction|
          direction = instance_variable_get(direction)
          builder << direction.to_xml if direction
        end
        builder.target!
      end

      ##
      # Runway direction
      #
      # Access runway direction instances via the runway:
      #   runway.name         # => "12/30"
      #   runway.forth.name   # => "12"
      #   runway.back.name    # => "30"
      class Direction
        attr_reader :runway, :name
        attr_reader :geographic_orientation, :xy, :z, :displaced_threshold, :remarks

        def initialize(runway:, name:)
          self.runway, self.name = runway, name
        end

        def runway=(value)
          fail(ArgumentError, "invalid runway") unless value.is_a? AIXM::Component::Runway
          @runway = value
        end
        private :runway

        ##
        # Name of the runway direction (e.g. "16R")
        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? String
          @name = value.uptrans
        end

        ##
        # Geographic orientation (true bearing) in degrees
        def geographic_orientation=(value)
          fail(ArgumentError, "invalid geographic orientation") unless value.respond_to? :to_i
          @geographic_orientation = value.to_i
          fail(ArgumentError, "invalid geographic orientation") unless (0..359).include? @geographic_orientation
        end

        ##
        # Beginning point (middle of the runway width)
        def xy=(value)
          fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
          @xy = value
        end

        ##
        # Elevation of the touch down zone in +qnh+
        def z=(value)
          fail(ArgumentError, "invalid z") unless value.is_a?(AIXM::Z) && value.qnh?
          @z = value
        end

        ##
        # Free text remarks
        def remarks=(value)
          @remarks = value&.to_s
        end

        ##
        # Displaced threshold point
        #
        # Allowed values:
        # * +AIXM::XY+ - coordinates of the point
        # * +Numeric+ - distance in meters from the beginning point
        def displaced_threshold=(value)
          @displaced_threshold = case value
            when AIXM::XY then @xy.distance(value).to_i
            when Numeric then value.to_i
            else fail(ArgumentError, "invalid displaced threshold")
          end
        end

        ##
        # Calculate the magnetic orientation (magnetic bearing) in degrees
        def magnetic_orientation
          if geographic_orientation && runway.airport.declination
            (geographic_orientation + runway.airport.declination).round
          end
        end

        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Rdn do |rdn|
            rdn.RdnUid do |rdn_uid|
              rdn_uid << runway.to_uid.indent(4)
              rdn_uid.txtDesig(name)
            end
            rdn.geoLat(xy.lat(AIXM.format))
            rdn.geoLong(xy.long(AIXM.format))
            rdn.valTrueBrg(geographic_orientation)
            rdn.valMagBrg(magnetic_orientation)
            if z
              rdn.valElevTdz(z.alt)
              rdn.uomElevTdz(z.unit.to_s)
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
        end
      end
    end
  end
end
