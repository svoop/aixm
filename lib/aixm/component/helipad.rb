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
    #   helipad.length = AIXM.d or nil   # must use same unit as width
    #   helipad.width = AIXM.d or nil    # must use same unit as length
    #   helipad.surface = AIXM.surface
    #   helipad.status = STATUSES or nil
    #   helipad.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airport#tla-helipad-tlof
    class Helipad
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

      # @return [AIXM::Z, nil] elevation in +:qnh+
      attr_reader :z

      # @return [AIXM::D, nil] length
      attr_reader :length

      # @return [AIXM::D, nil] width
      attr_reader :width

      # @return [AIXM::Component::Surface] surface of the helipad
      attr_reader :surface

      # @return [Symbol, nil] status of the helipad (see {STATUSES}) or +nil+ for normal operation
      attr_reader :status

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(name:)
        self.name = name
        @surface = AIXM.surface
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} airport=#{airport&.id.inspect} name=#{name.inspect}>)
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
          tla.valLen(length.dist.trim) if length
          tla.valWid(width.dist.trim) if width
          tla.uomDim(length.unit.to_s.upcase) if length
          tla.uomDim(width.unit.to_s.upcase) if width && !length
          unless  (xml = surface.to_xml).empty?
            tla << xml.indent(2)
          end
          tla.codeSts(STATUSES.key(status).to_s) if status
          tla.txtRmk(remarks) if remarks
        end
      end
    end
  end
end
