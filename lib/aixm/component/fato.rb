using AIXM::Refinements

module AIXM
  class Component

    # FATO (final approach and take-off area) for vertical take-off aircraft
    # such as helicopters.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   fato = AIXM.fato(
    #     name: String
    #   )
    #   fato.length = AIXM.d or nil   # must use same unit as width
    #   fato.width = AIXM.d or nil    # must use same unit as length
    #   fato.surface = AIXM.surface
    #   fato.marking = String or nil
    #   fato.profile = String or nil
    #   fato.status = STATUSES or nil
    #   fato.remarks = String or nil
    #   fato.add_direction(
    #     name: String
    #   ) do |direction|
    #     direction.geographic_orientation = AIXM.a[precision=3] or nil
    #     direction.remarks = String or nil
    #   end
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airport#fto-fato
    class FATO
      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,          # e.g. construction work
        PARKED: :parked_aircraft,        # parked or disabled aircraft on FATO
        FAILAID: :visual_aids_failure,   # failure or irregular operation of visual aids
        SPOWER: :secondary_power,        # secondary power supply in operation
        OTHER: :other                    # specify in remarks
      }.freeze

      # @return [AIXM::Feature::Airport] airport this FATO belongs to
      attr_reader :airport

      # @return [String] full name (e.g. "H1")
      attr_reader :name

      # @return [AIXM::D, nil] length
      attr_reader :length

      # @return [AIXM::D, nil] width
      attr_reader :width

      # @return [AIXM::Component::Surface] surface of the FATO
      attr_reader :surface

      # @return [String, nil] markings
      attr_reader :marking

      # @return [String, nil] profile description
      attr_reader :profile

      # @return [Symbol, nil] status of the FATO (see {STATUSES}) or +nil+ for normal operation
      attr_reader :status

      # @return [String, nil] free text remarks
      attr_reader :remarks

      # @return [Hash{String => AIXM::Component::FATO::Direction}] maps added direction names to full FATO directions
      attr_reader :directions

      def initialize(name:)
        self.name = name
        @surface = AIXM.surface
        @directions = {}
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

      def marking=(value)
        @marking = value&.to_s
      end

      def profile=(value)
        @profile = value&.to_s
      end

      def status=(value)
        @status = value.nil? ? nil : (STATUSES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid status"))
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      def add_direction(name:)
        direction = Direction.new(fato: self, name: name)
        yield direction
        @directions[name] = direction
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.FtoUid do |fto_uid|
          fto_uid << airport.to_uid.indent(2)
          fto_uid.txtDesig(name)
        end.insert_payload_hash(region: AIXM.config.mid_region)
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Fto do |fto|
          fto << to_uid.indent(2)
          fto.valLen(length.dist.trim) if length
          fto.valWid(width.dist.trim) if width
          fto.uomDim(length.unit.to_s.upcase) if length
          fto.uomDim(width.unit.to_s.upcase) if width && !length
          unless  (xml = surface.to_xml).empty?
            fto << xml.indent(2)
          end
          fto.txtProfile(profile) if profile
          fto.txtMarking(marking) if marking
          fto.codeSts(STATUSES.key(status).to_s) if status
          fto.txtRmk(remarks) if remarks
        end
        directions.values.each do |direction|
          builder << direction.to_xml
        end
        builder.target!
      end

      # FATO directions further describe each direction to and from the FATO.
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Airport#fdn-fato-direction
      class Direction

        # @return [AIXM::Component::FATO] FATO the FATO direction is further describing
        attr_reader :fato

        # @return [AIXM::A] name of the FATO direction (e.g. "12" or "16L")
        attr_reader :name

        # @return [AIXM::A, nil] geographic orientation (true bearing) in degrees
        attr_reader :geographic_orientation

        # @return [String, nil] free text remarks
        attr_reader :remarks

        # @return [Array<AIXM::Component::Lighting>] installed lighting systems
        attr_reader :lightings

        def initialize(fato:, name:)
          self.fato, self.name = fato, name
          @lightings = []
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} airport=#{fato&.airport&.id.inspect} name=#{name.inspect}>)
        end

        def fato=(value)
          fail(ArgumentError, "invalid FATO") unless value.is_a? AIXM::Component::FATO
          @fato = value
        end
        private :fato

        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? String
          @name = AIXM.a(value)
        end

        def geographic_orientation=(value)
          return @geographic_orientation = nil if value.nil?
          fail(ArgumentError, "invalid geographic orientation") unless value.is_a? AIXM::A
          @geographic_orientation = value
        end

        def remarks=(value)
          @remarks = value&.to_s
        end

        # Add a lighting system to the FATO direction.
        #
        # @param lighting [AIXM::Component::Lighting] lighting instance
        # @return [self]
        def add_lighting(lighting)
          fail(ArgumentError, "invalid lighting") unless lighting.is_a? AIXM::Component::Lighting
          lighting.send(:lightable=, self)
          @lightings << lighting
          self
        end

        # @return [AIXM::A] magnetic orientation (magnetic bearing) in degrees
        def magnetic_orientation
          if geographic_orientation && fato.airport.declination
            geographic_orientation - fato.airport.declination
          end
        end

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.FdnUid do |fdn_uid|
            fdn_uid << fato.to_uid.indent(2)
            fdn_uid.txtDesig(name)
          end.insert_payload_hash(region: AIXM.config.mid_region)
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Fdn do |fdn|
            fdn << to_uid.indent(2)
            fdn.valTrueBrg(geographic_orientation) if geographic_orientation
            fdn.valMagBrg(magnetic_orientation) if magnetic_orientation
            fdn.txtRmk(remarks) if remarks
          end
          lightings.each do |lighting|
            builder << lighting.to_xml(as: :Fls)
          end
          builder.target!
        end
      end
    end
  end
end
