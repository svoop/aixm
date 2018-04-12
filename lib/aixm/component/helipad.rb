using AIXM::Refinements

module AIXM
  class Component

    # Helipads are TLOF (touch-down and lift-off areas) e.g. for helicopters.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   helipad = AIXM.helipad(
    #     name: String
    #   )
    #   helipad.xy = AIXM.xy
    #   helipad.z = AIXM.z or nil
    #   helipad.length = Integer or nil   # meters
    #   helipad.width = Integer or nil    # meters
    #   helipad.composition = COMPOSITIONS or nil
    #   helipad.status = STATUSES or nil
    #   helipad.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airport#tla-helipad-tlof
    class Helipad
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
      }.freeze

      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,          # e.g. construction work
        PARKED: :parked_aircraft,        # parked or disabled aircraft on helipad
        FAILAID: :visual_aids_failure,   # failure or irregular operation of visual aids
        SPOWER: :secondary_power,        # secondary power supply in operation
        OTHER: :other                    # specify in remarks
      }.freeze

      # @return [AIXM::Feature::Airport] airport this helipad belongs to
      attr_reader :airport

      # @return [String] full name (e.g. "H1")
      attr_reader :name

      # @return [AIXM::XY] center point
      attr_reader :xy

      # @return [AIXM:Z, nil] elevation in +:qnh+
      attr_reader :z

      # @return [Integer, nil] length in meters
      attr_reader :length

      # @return [Integer, nil] width in meters
      attr_reader :width

      # @return [Symbol, nil] composition of the surface (see {COMPOSITIONS})
      attr_reader :composition

      # @return [Symbol, nil] status of the helipad (see {STATUSES}) or +nil+ for normal operation
      attr_reader :status

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(name:)
        self.name = name
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

      def xy=(value)
        fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
        @xy = value
      end

      def z=(value)
        fail(ArgumentError, "invalid z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
        @z = value
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
        builder.TlaUid do |tla_uid|
          tla_uid << airport.to_uid.indent(2)
          tla_uid.txtDesig(name)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Tla do |tla|
          tla << to_uid.indent(2)
          tla.geoLat(xy.lat(AIXM.schema))
          tla.geoLong(xy.long(AIXM.schema))
          tla.codeDatum('WGE')
          if z
            tla.valElev(z.alt)
            tla.uomDistVer(z.unit.upcase.to_s)
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
