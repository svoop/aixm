using AIXM::Refinements

module AIXM
  module Component

    ##
    # Helipads are TLOF (touch-down and lift-off areas)
    #
    #
    # Arguments:
    # * +name+ - name of the helipad
    class Helipad
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

      attr_reader :airport
      attr_reader :name
      attr_reader :xy, :z, :length, :width, :composition, :status, :remarks

      def initialize(name:)
        self.name = name
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
      # Name of the helipad (e.g. "H1")
      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      ##
      # Center point
      def xy=(value)
        fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
        @xy = value
      end

      ##
      # Elevation in +qnh+
      def z=(value)
        fail(ArgumentError, "invalid z") unless value.is_a?(AIXM::Z) && value.qnh?
        @z = value
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
      # Helipad status
      #
      # Allowed values:
      # * +nil+ - normal operation
      # * +:closed+ (+:CLSD+)
      # * +:work_in_progress+ (+:WIP+) - e.g. construction work
      # * +:parked_aircraft+ (+:PARKED+) - parked or disabled aircraft on helipad
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
        builder.TlaUid do |tla_uid|
          tla_uid << airport.to_uid.indent(2)
          tla_uid.txtDesig(name)
        end
      end

      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Tla do |tla|
          tla << to_uid.indent(2)
          tla.geoLat(xy.lat(AIXM.schema))
          tla.geoLong(xy.long(AIXM.schema))
          tla.codeDatum('WGE')
          if z
            tla.valElev(z.alt)
            tla.uomDistVer(z.unit.to_s)
          end
          tla.valLen(length) if length
          tla.valWid(width) if width
          tla.uomDim('M') if length || width
          tla.codeComposition(COMPOSITIONS.key(composition).to_s) if composition
          tla.codeSts(STATUSES.key(status).to_s) if status
          tla.txtRmk(remarks) if remarks
        end
      end
    end
  end
end
