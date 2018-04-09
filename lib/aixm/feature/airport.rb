using AIXM::Refinements

module AIXM
  class Feature

    # Defined area on land or water to be used for the arrival, departure and
    # surface movement of aircraft.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   airport = AIXM.airport(
    #     source: String or nil
    #     region: String or nil (falls back to AIXM.config.region)
    #     organisation: AIXM.organisation
    #     code: String
    #     name: String
    #     xy: AIXM.xy
    #   )
    #   airport.gps = String
    #   airport.type = TYPES
    #   airport.z = AIXM.z
    #   airport.declination = Float
    #   airport.transition_z = AIXM.z
    #   airport.schedule = AIXM.schedule or nil
    #   airport.remarks = String or nil
    #   airport.add_runway(AIXM.runway)
    #   airport.add_helipad(AIXM.helipad)
    #   airport.add_usage_limitation(UsageLimitation::TYPES)
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airport#ahp-airport
    class Airport < Feature
      public_class_method :new

      CODE_PATTERN = /^[A-Z]{2}([A-Z]{1,2}|\d{4})$/.freeze

      TYPES = {
        AD: :aerodrome,
        HP: :heliport,
        AH: :aerodrome_and_heliport,
        LS: :landing_site
      }

      # @return [AIXM::Feature::Organisation] superior organisation
      attr_reader :organisation

      # ICAO indicator, IATA indicator or ICAO serial number
      #
      # * four letter ICAO indicator (e.g. "LFMV")
      # * three letter IATA indicator (e.g. "AVN")
      # * two letter ICAO country code + four digit number (e.g. "LF1234")
      #
      # @return [String] airport indicator code
      attr_reader :code

      # @return [String] full name
      attr_reader :name

      # @return [AIXM::XY] reference point
      attr_reader :xy

      # @return [String] GPS code
      attr_reader :gps

      # @return [AIXM::Z] elevation in +:qnh+
      attr_reader :z

      # When looking towards the geographic (aka: true) north, a positive
      # declination represents the magnetic north is to the right (aka: east)
      # by this angle.
      #
      # @see https://en.wikipedia.org/wiki/Magnetic_declination
      # @return [Float] magnetic declination in degrees
      attr_reader :declination

      # @return [AIXM::Z] transition altitude in :+qnh+
      attr_reader :transition_z

      # @return [AIXM::Component::Schedule, nil] operating hours
      attr_reader :schedule

      # @return [String] free text remarks
      attr_reader :remarks

      # @return [Array<AIXM::Component::Runway>] runways present at this airport
      attr_reader :runways

      # @return [Array<AIXM::Component::Helipad>] helipads present at this airport
      attr_reader :helipads

      # @return [Array<AIXM::Feature::Airport::UsageLimitation>] usage limitations
      attr_accessor :usage_limitations

      def initialize(source: nil, region: nil, organisation:, code:, name:, xy:)
        super(source: source, region: region)
        self.organisation, self.code, self.name, self.xy = organisation, code, name, xy
        @runways, @helipads, @usage_limitations = [], [], []
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} code=#{code.inspect}>)
      end

      def organisation=(value)
        fail(ArgumentError, "invalid organisation") unless value.is_a? AIXM::Feature::Organisation
        @organisation = value
      end

      def code=(value)
        fail(ArgumentError, "invalid code `#{code}'") unless value.upcase.match? CODE_PATTERN
        @code = value.upcase
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def gps=(value)
        fail(ArgumentError, "invalid gps") unless value.nil? || value.is_a?(String)
        @gps = value&.upcase
      end

      # The type is usually derived from the presence of runways and helipads,
      # however, this may be overridden by setting an alternative value, most
      # notably +:landing_site+.
      #
      # @return [Symbol] type of airport (see {TYPES})
      def type
        @type = case
          when @type then @type
          when runways.any? && helipads.any? then :aerodrome_and_heliport
          when runways.any? then :aerodrome
          when helipads.any? then :heliport
        end
      end

      def type=(value)
        resolved_value = TYPES.lookup(value&.to_sym, nil)
        fail(ArgumentError, "invalid type") unless resolved_value == :landing_site
        @type = resolved_value
      end

      def xy=(value)
        fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
        @xy = value
      end

      def z=(value)
        fail(ArgumentError, "invalid z") unless value.is_a?(AIXM::Z) && value.qnh?
        @z = value
      end

      def declination=(value)
        fail(ArgumentError, "invalid declination") unless value.respond_to? :to_f
        @declination = value
        fail(ArgumentError, "invalid declination") unless (-180..180).include?(@declination)
      end

      def transition_z=(value)
        fail(ArgumentError, "invalid transition_z") unless value.is_a?(AIXM::Z) && value.qnh?
        @transition_z = value
      end

      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # Add a runway to the airport.
      #
      # @param runway [AIXM::Component::Runway] runway instance
      # @return [self]
      def add_runway(runway)
        fail(ArgumentError, "invalid runway") unless runway.is_a? AIXM::Component::Runway
        runway.send(:airport=, self)
        @runways << runway
        self
      end

      # Add a helipad to the airport.
      #
      # @param helipad [AIXM::Component::Helipad] helipad instance
      # @return [self]
      def add_helipad(helipad)
        fail(ArgumentError, "invalid helipad") unless helipad.is_a? AIXM::Component::Helipad
        helipad.send(:airport=, self)
        @helipads << helipad
        self
      end

      # Add an airport usage limitation.
      #
      # See {AIXM::Feature::Airport::UsageLimitation::TYPES UsageLimitation::TYPES}
      # for recognized limitations and {AIXM::Feature::Airport::UsageLimitation#add_condition UsageLimitation#add_condition}
      # for recognized conditions.
      #
      # Multiple conditions are joined with an implicit *or* whereas the
      # specifics of a condition (aircraft, rule etc) are joined with an
      # implicit *and*.
      #
      # @example Limitation applying to any traffic
      #   airport.add_usage_limitation(:permitted)
      #
      # @example Limitation applying to specific traffic
      #   airport.add_usage_limitation(:reservation_required) do |reservation_required|
      #     reservation_required.add_condition do |condition|
      #       condition.aircraft = :glider
      #     end
      #     reservation_required.add_condition do |condition|
      #       condition.rule = :ifr
      #       condition.origin = :international
      #     end
      #     reservation_required.schedule = AIXM::H24
      #     reservation_required.remarks = "Reservation 24 HRS prior to arrival"
      #   end
      #
      # @yieldparam usage_limitation [AIXM::Feature::Airport::UsageLimitation]
      # @return [self]
      def add_usage_limitation(type)
        usage_limitation = UsageLimitation.new(type: type)
        yield(usage_limitation) if block_given?
        @usage_limitations << usage_limitation
        self
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.AhpUid({ region: (region if AIXM.ofmx?) }.compact) do |ahp_uid|
          ahp_uid.codeId(code)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Ahp({ source: (source if AIXM.ofmx?) }.compact) do |ahp|
          ahp << to_uid.indent(2)
          ahp << organisation.to_uid.indent(2)
          ahp.txtName(name)
          ahp.codeIcao(code) if code.length == 4
          ahp.codeIata(code) if code.length == 3
          ahp.codeGps(gps) if AIXM.ofmx? && gps
          ahp.codeType(TYPES.key(type).to_s)
          ahp.geoLat(xy.lat(AIXM.schema))
          ahp.geoLong(xy.long(AIXM.schema))
          ahp.codeDatum('WGE')
          if z
            ahp.valElev(z.alt)
            ahp.uomDistVer(z.unit.to_s)
          end
          ahp.valMagVar(declination) if declination
          if transition_z
            ahp.valTransitionAlt(transition_z.alt)
            ahp.uomTransitionAlt(transition_z.unit.to_s)
          end
          ahp << schedule.to_xml(as: :Aht).indent(2) if schedule
          ahp.txtRmk(remarks) if remarks
        end
        runways.each do |runway|
          builder << runway.to_xml
        end
        helipads.each do |helipad|
          builder << helipad.to_xml
        end
        if usage_limitations.any?
          builder.Ahu do |ahu|
            ahu.AhuUid do |ahu_uid|
              ahu_uid << to_uid.indent(4)
            end
            usage_limitations.each do |usage_limitation|
              ahu << usage_limitation.to_xml.indent(2)
            end
          end
        end
        builder.target!
      end

      # Limitations concerning the availability of an airport for certain flight
      # types, aircraft types etc during specific hours.
      #
      # @see AIXM::Feature::Airport#add_usage_limitation
      # @see https://github.com/openflightmaps/ofmx/wiki/Airport#ahu-airport-usage
      class UsageLimitation
        TYPES = {
          PERMIT: :permitted,
          FORBID: :forbidden,
          RESERV: :reservation_required,
          OTHER: :other                    # specify in remarks
        }.freeze

        # @return [AIXM::Feature::Airport] airport this usage limitation is assigned to
        attr_reader :airport

        # @return [Symbol] type of limitation
        attr_reader :type

        # @return [Array<AIXM::Feature::Airport::UsageLimitation::Condition>] conditions for this limitation to apply
        attr_reader :conditions

        # @return [AIXM::Component::Schedule, nil] limitation application hours
        attr_reader :schedule

        # @return [String] free text remarks
        attr_reader :remarks

        def initialize(type:)
          self.type = type
          @conditions = []
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} type=#{type.inspect}>)
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        # Add a condition to the usage limitation.
        #
        # @yieldparam condition [AIXM::Feature::Airport::UsageLimitation::Condition]
        # @return [self]
        def add_condition
          condition = Condition.new
          yield(condition)
          @conditions << condition
          self
        end

        def schedule=(value)
          fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
          @schedule = value
        end

        def remarks=(value)
          @remarks = value&.to_s
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.UsageLimitation do |usage_limitation|
            usage_limitation.codeUsageLimitation(TYPES.key(type).to_s)
            conditions.each do |condition|
              usage_limitation << condition.to_xml.indent(2)
            end
            usage_limitation << schedule.to_xml(as: :Timetable).indent(2) if schedule
            usage_limitation.txtRmk(remarks) if remarks
          end
        end

        # Flight and/or aircraft characteristics used to target a usage
        # limitation.
        #
        # @see AIXM::Feature::Airport#add_usage_limitation
        # @see https://github.com/openflightmaps/ofmx/wiki/Airport#ahu-airport-usage
        class Condition
          AIRCRAFT = {
            L: :landplane,
            S: :seaplane,
            A: :amphibian,
            H: :helicopter,
            G: :gyrocopter,
            T: :tilt_wing,
            R: :short_takeoff_and_landing,
            E: :glider,
            N: :hangglider,
            P: :paraglider,
            U: :ultra_light,
            B: :balloon,
            D: :unmanned_drone,
            OTHER: :other                    # specify in remarks
          }.freeze

          RULES = {
            I: :ifr,
            V: :vfr,
            IV: :ifr_and_vfr
          }.freeze

          REALMS = {
            CIVIL: :civil,
            MIL: :military,
            OTHER: :other     # specify in remarks
          }.freeze

          ORIGINS = {
            NTL: :national,
            INTL: :international,
            ANY: :any,
            OTHER: :other           # specify in remarks
          }.freeze

          PURPOSES = {
            S: :scheduled,
            NS: :not_scheduled,
            P: :private,
            TRG: :school_or_training,
            WORK: :aerial_work,
            OTHER: :other               # specify in remarks
          }.freeze

          # @return [Symbol] kind of aircraft (see {AIRCRAFT})
          attr_reader :aircraft

          # @return [String] flight rule (see {RULES})
          attr_reader :rule

          # @return [String] whether military or civil (see {REALMS})
          attr_reader :realm

          # @return [String] geographic origin of the flight (see {ORIGINS})
          attr_reader :origin

          # @return [String] purpose of the flight (see {PURPOSES})
          attr_reader :purpose

          # @return [String]
          def inspect
            %Q(#<#{self.class} aircraft=#{aircraft.inspect} rule=#{rule.inspect} realm=#{realm.inspect} origin=#{origin.inspect} purpose=#{purpose.inspect}>)
          end

          def aircraft=(value)
            @aircraft = AIRCRAFT.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid aircraft")
          end

          def rule=(value)
            @rule = RULES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid rule")
          end

          def realm=(value)
            @realm = REALMS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid realm")
          end

          def origin=(value)
            @origin = ORIGINS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid origin")
          end

          def purpose=(value)
            @purpose = PURPOSES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid purpose")
          end

          # @return [String] AIXM or OFMX markup
          def to_xml
            builder = Builder::XmlMarkup.new(indent: 2)
            builder.UsageCondition do |usage_condition|
              if aircraft
                usage_condition.AircraftClass do |aircraft_class|
                  aircraft_class.codeType(AIRCRAFT.key(aircraft).to_s)
                end
              end
              if rule || realm || origin || purpose
                usage_condition.FlightClass do |flight_class|
                  flight_class.codeRule(RULES.key(rule).to_s) if rule
                  flight_class.codeMil(REALMS.key(realm).to_s) if realm
                  flight_class.codeOrigin(ORIGINS.key(origin).to_s) if origin
                  flight_class.codePurpose(PURPOSES.key(purpose).to_s) if purpose
                end
              end
            end
          end
        end
      end
    end
  end
end
