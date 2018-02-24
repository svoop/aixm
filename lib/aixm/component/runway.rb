module AIXM
  module Component

    ##
    # Runways are landing and takeoff strips
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
    #
    # By convention, the runway name is usually the composition of the runway
    # forth name (smaller number) and the runway hence name (bigger number)
    # joined with a forward slash.
    class Runway < Base
      using AIXM::Refinements

      COMPOSITIONS = {
        ASPH: :asphalt,
        BITUM: :bitumen,
        CONC: :concrete,
        GRAVE: :gravel,
        MACADAM: :macadam,
        SAND: :sand,
        GRADE: :graded_earth,
        GRASS: :grass,
        WATER: :water
      }

      attr_reader :airport
      attr_reader :name, :length, :width, :composition, :remarks
      attr_accessor :forth, :back

      def initialize(airport:, name:)
        fail(ArgumentError, "illegal airport") unless airport.is_a? AIXM::Feature::Airport
        fail(ArgumentError, "illegal name") unless name.is_a? String
        @airport, @name = airport, name.uptrans
        @name.split('/').tap do |forth, back|
          @forth = Direction.new(runway: self, name: forth)
          @back = Direction.new(runway: self, name: back) if back
        end
      end

      ##
      # Length in meters
      def length=(value)
        fail(ArgumentError, "illegal length") unless value.is_a?(Numeric) && value > 0
        @length = value.to_i
      end

      ##
      # Width in meters
      def width=(value)
        fail(ArgumentError, "illegal width") unless value.is_a?(Numeric)  && value > 0
        @width = value.to_i
      end

      ##
      # Composition of the surface
      #
      # Allowed values:
      # * +:asphalt+
      # * +:concrete+
      # * +:bitumen+ - dug up, bound and rolled ground
      # * +:gravel+ - small and midsize rounded stones
      # * +:macadam+ - small rounded stones
      # * +:sand+
      # * +:graded_earth+ - graded or rolled earth possibly with some grass
      # * +:grass+ - lawn
      # * +:water+
      def composition=(value)
        @composition = COMPOSITIONS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid composition")
      end

      def composition_key
        COMPOSITIONS.key(north)
      end

      ##
      # Free text with further details
      def remarks=(value)
        @remarks = value&.to_s
      end

      ##
      # Digest to identify the payload
      def to_digest
        [].to_digest
      end

      ##
      # Render UID markup
      def to_uid
        mid = to_digest
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.RwyUid({ mid: mid, newEntity: (true if AIXM.ofmx?) }.compact) do |rwyuid|
          rwyuid << ahp.to_uid
          rwyuid.txtDesig(name)
        end
      end

      ##
      # Render XML
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Rwy do |rwy|
          rwy << to_uid
          rwy.valLen(length)
          rwy.valWid(width)
          rwy.uomDimRwy('M')
          rwy.codeComosition(composition_key.to_s)
          rwy.txtRmk(remarks)
        end
        %i(@forth @back).each do |direction|
          direction = instance_variable_get(direction)
          builder << direction.to_xml if direction
        end
      end

      ##
      # Runway direction
      class Direction
        using AIXM::Refinements

        attr_reader :runway
        attr_reader :name, :geographic_orientation, :xy, :displaced_threshold

        def initialize(runway:, name:)
          fail(ArgumentError, "illegal runway") unless runway.is_a? AIXM::Component::Runway
          @runway, self.name = runway, name
        end

        ##
        # Overwrite preset runway direction name
        def name=(value)
          fail(ArgumentError, "illegal name") unless value.is_a? String
          @name = value.uptrans
        end

        ##
        # Geographic orientation (true bearing) in degrees
        def geographic_orientation=(value)
          @geographic_orientation = value.to_i
          fail(ArgumentError, "illegal geographic orientation") unless (0..359).include? @geographic_orientation
        end

        ##
        # Beginning point (middle of the runway width)
        def xy=(value)
          fail(ArgumentError, "illegal xy") unless value.is_a? AIXM::XY
          @xy = value
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
            else fail(ArgumentError, "illegal displaced threshold")
          end
        end

        ##
        # Calculate the magnetic orientation (bearing) in degrees
        def magnetic_orientation
          (geographic_orientation + runway.airport.declination).round
        end

        ##
        # Digest to identify the payload
        def to_digest
          [name, xy.to_digest, displaced_threshold].to_digest
        end

        ##
        # Render XML
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Rdn do |rdn|
            rdn.RdnUid do |rdnuid|
              rdnuid.RwyUid do |rwyuid|
              end
              rdnuid.txtDesign(name)
            end
            rdn.geoLat(xy.lat)
            rdn.geoLong(xy.long)
            rdn.valTrueBrg()
            rdn.magBrg()
            rdn.valElevTdz()
            rdn.uomElevTdz()
            rdn.txtRmk()
          end
          builder.Rdd do |rdd|
            builder.RddUid do |rdduid|
              builder.RdnUid do |rdnuid|
                builder.RwyUid do |rwyuid|
                end
              end
              rdduid.codeType()
              rdduid.codeDayPeriod()
            end
            rdd.valDist()
            rdd.uomDist()
            rdd.txtRmk()
          end
        end
      end

    end
  end
end
