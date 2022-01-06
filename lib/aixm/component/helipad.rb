using AIXM::Refinements

module AIXM
  class Component

    # Helipads are TLOF (touch-down and lift-off areas) for vertical take-off
    # aircraft such as helicopters.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   helipad = AIXM.helipad(
    #     name: String
    #     xy: AIXM.xy
    #   )
    #   helipad.z = AIXM.z or nil
    #   helipad.dimensions = AIXM.r or nil
    #   helipad.surface = AIXM.surface
    #   helipad.marking = String or nil
    #   helipad.add_lighting = AIXM.lighting
    #   helipad.fato = AIXM.fato or nil
    #   helipad.performance_class = PERFORMANCE_CLASSES or nil
    #   helipad.status = STATUSES or nil
    #   helipad.remarks = String or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#tla-helipad-tlof
    class Helipad < Component
      include AIXM::Association
      include AIXM::Memoize

      PERFORMANCE_CLASSES = {
        '1': :'1',
        '2': :'2',
        '3': :'3',
        OTHER: :other   # specify in remarks
      }.freeze

      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,          # e.g. construction work
        PARKED: :parked_aircraft,        # parked or disabled aircraft on helipad
        FAILAID: :visual_aids_failure,   # failure or irregular operation of visual aids
        SPOWER: :secondary_power,        # secondary power supply in operation
        OTHER: :other                    # specify in remarks
      }.freeze

      # @!method fato
      #   @return [AIXM::Component::FATO, nil] FATO the helipad is situated on
      #
      # @!method fato=(fato)
      #   @param fato [AIXM::Component::FATO, nil]
      has_one :fato, allow_nil: true

      # @!method surface
      #   @return [AIXM::Component::Surface] surface of the helipad
      #
      # @!method surface=(surface)
      #   @param surface [AIXM::Component::Surface]
      has_one :surface, accept: 'AIXM::Component::Surface'

      # @!method lightings
      #   @return [Array<AIXM::Component::Lighting>] installed lighting systems
      #
      # @!method add_lighting(lighting)
      #   @param lighting [AIXM::Component::Lighting]
      #   @return [self]
      has_many :lightings, as: :lightable

      # @!method airport
      #   @return [AIXM::Feature::Airport] airport this helipad belongs to
      belongs_to :airport

      # @return [String] full name (e.g. "H1")
      attr_reader :name

      # @return [AIXM::XY] center point
      attr_reader :xy

      # @return [AIXM::Z, nil] elevation in +:qnh+
      attr_reader :z

      # @return [AIXM::R, nil] dimensions
      attr_reader :dimensions

      # @return [String, nil] markings
      attr_reader :marking

      # @return [Integer, Symbol, nil] suitable performance class
      attr_reader :performance_class

      # @return [Symbol, nil] status of the helipad (see {STATUSES}) or +nil+ for normal operation
      attr_reader :status

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(name:, xy:)
        self.name, self.xy = name, xy
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

      def xy=(value)
        fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
        @xy = value
      end

      def z=(value)
        fail(ArgumentError, "invalid z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
        @z = value
      end

      def dimensions=(value)
        fail(ArgumentError, "invalid dimensions") unless value.nil? || value.is_a?(AIXM::R)
        @dimensions = value
      end

      def marking=(value)
        @marking = value&.to_s
      end

      def performance_class=(value)
        @performance_class = value.nil? ? nil : (PERFORMANCE_CLASSES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid performance class"))
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
      memoize :to_uid

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Tla do |tla|
          tla << to_uid.indent(2)
          tla << fato.to_uid.indent(2) if fato
          tla.geoLat(xy.lat(AIXM.schema))
          tla.geoLong(xy.long(AIXM.schema))
          tla.codeDatum('WGE')
          if z
            tla.valElev(z.alt)
            tla.uomDistVer(z.unit.upcase.to_s)
          end
          if dimensions
            tla.valLen(dimensions.length.to_m.dim.trim)
            tla.valWid(dimensions.width.to_m.dim.trim)
            tla.uomDim('M')
          end
          unless  (xml = surface.to_xml).empty?
            tla << xml.indent(2)
          end
          tla.codeClassHel(PERFORMANCE_CLASSES.key(performance_class).to_s) if performance_class
          tla.txtMarking(marking) if marking
          tla.codeSts(STATUSES.key(status).to_s) if status
          tla.txtRmk(remarks) if remarks
        end
        lightings.each do |lighting|
          builder << lighting.to_xml(as: :Tls)
        end
        builder.target!
      end
    end
  end
end
