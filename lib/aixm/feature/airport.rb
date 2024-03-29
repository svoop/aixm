using AIXM::Refinements

module AIXM
  class Feature

    # Defined area on land or water to be used for the arrival, departure and
    # surface movement of aircraft.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   airport = AIXM.airport(
    #     source: String or nil
    #     region: String or nil
    #     organisation: AIXM.organisation
    #     id: String
    #     name: String
    #     xy: AIXM.xy
    #   )
    #   airport.gps = String or nil
    #   airport.type = TYPES (other than AD, HP and AH only)
    #   airport.z = AIXM.z or nil
    #   airport.declination = Float or nil
    #   airport.transition_z = AIXM.z or nil
    #   airport.timetable = AIXM.timetable or nil
    #   airport.operator = String or nil
    #   airport.remarks = String or nil
    #   airport.comment = Object or nil
    #   airport.add_runway(AIXM.runway)
    #   airport.add_fato(AIXM.fato)
    #   airport.add_helipad(AIXM.helipad)
    #   airport.add_usage_limitation(UsageLimitation::TYPES)
    #   airport.add_unit(AIXM.unit)
    #   airport.add_service(AIXM.service)
    #   airport.add_address(AIXM.address)
    #
    # For airports without an +id+, you may assign the two character region
    # (e.g. "LF") which will be combined with an 8 character digest of +name+.
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#ahp-airport
    class Airport < Feature
      include AIXM::Concerns::Association
      include AIXM::Concerns::Timetable
      include AIXM::Concerns::Remarks

      public_class_method :new

      ID_RE = /^([A-Z]{3,4}|[A-Z]{2}[A-Z\d]{4,})$/.freeze

      TYPES = {
        AD: :aerodrome,
        HP: :heliport,
        AH: :aerodrome_and_heliport,
        LS: :landing_site
      }.freeze

      # @!method fatos
      #   @return [Array<AIXM::Component::FATO>] FATOs present at this airport
      #
      # @!method add_fato(fato)
      #   @param fato [AIXM::Component::FATO]
      has_many :fatos

      # @!method helipads
      #   @return [Array<AIXM::Component::Helipad>] helipads present at this airport
      #
      # @!method add_helipad(helipad)
      #   @param helipad [AIXM::Component::Helipad]
      has_many :helipads

      # @!method runways
      #   @return [Array<AIXM::Component::Runway>] runways present at this airport
      #
      # @!method add_runway(runway)
      #   @param runway [AIXM::Component::Runway]
      has_many :runways

      # @!method usage_limitations
      #   @return [Array<AIXM::Feature::Airport::UsageLimitation>] usage limitations
      #
      # @!method add_usage_limitation
      #   @yield [AIXM::Feature::Airport::UsageLimitation]
      #   @return [self]
      has_many :usage_limitations, accept: 'AIXM::Feature::Airport::UsageLimitation' do |usage_limitation, type:| end

      # @!method designated_points
      #   @return [Array<AIXM::Feature::NavigationalAid::DesignatedPoint>] designated points
      #
      # @!method add_designated_point(designated_point)
      #   @param designated_point [AIXM::Feature::NavigationalAid::DesignatedPoint]
      has_many :designated_points

      # @!method units
      #   @return [Array<AIXM::Feature::Unit>] units
      #
      # @!method add_unit(unit)
      #   @param unit [AIXM::Feature::Unit]
      has_many :units

      # @!method services
      #   @return [Array<AIXM::Component::Service>] services
      #
      # @!method add_service(service)
      #   @param service [AIXM::Component::Service]
      has_many :services

      # @!method addresses
      #   @return [Array<AIXM::Feature::Address>] postal address, url, A/A or A/G frequency etc
      #
      # @!method add_address(address)
      #   @param address [AIXM::Feature::Address]
      #   @return [self]
      has_many :addresses, as: :addressable

      # @!method organisation
      #   @return [AIXM::Feature::Organisation] superior organisation
      belongs_to :organisation, as: :member

      # ICAO, IATA or generated airport indicator.
      #
      # * four letter ICAO indicator (e.g. "LFMV")
      # * three letter IATA indicator (e.g. "AVN")
      # * two letter ICAO country code + four digit number (e.g. "LF1234")
      # * two letter ICAO country code + at least four letters/digits (e.g.
      #   "LFFOOBAR123" or "LF" + GPS code)
      #
      # @overload id
      #   @return [String]
      # @overload id=(value)
      #   @param value [String]
      attr_reader :id

      # Full name
      #
      # @overload name
      #   @return [String]
      # @overload name=(value)
      #   @param value [String]
      attr_reader :name

      # Reference point
      #
      # @overload xy
      #   @return [AIXM::XY]
      # @overload xy=(value)
      #   @param value [AIXM::XY]
      attr_reader :xy

      # GPS code
      #
      # @overload gps
      #   @return [String, nil]
      # @overload gps=(value)
      #   @param value [String, nil]
      attr_reader :gps

      # Elevation in +:qnh+
      #
      # @overload z
      #   @return [AIXM::Z, nil]
      # @overload z=(value)
      #   @param value [AIXM::Z, nil]
      attr_reader :z

      # When looking towards the geographic (aka: true) north, a positive
      # declination represents the magnetic north is to the right (aka: east)
      # by this angle.
      #
      # To convert a magnetic bearing to the corresponding geographic (aka:
      # true) bearing, the declination has to be added.
      #
      # @see https://en.wikipedia.org/wiki/Magnetic_declination
      # @return [Float, nil] magnetic declination in degrees
      attr_reader :declination

      # Transition altitude in +:qnh+
      #
      # @overload transition_z
      #   @return [AIXM::Z, nil]
      # @overload transition_z=(value)
      #   @param value [AIXM::Z, nil]
      attr_reader :transition_z

      # Operator of the airport
      #
      # @overload operator
      #   @return [String, nil]
      # @overload operator=(value)
      #   @param value [String, nil]
      attr_reader :operator

      # See the {cheat sheet}[AIXM::Feature::Airport] for examples on how to
      # create instances of this class.
      def initialize(source: nil, region: nil, organisation:, id: nil, name:, xy:)
        super(source: source, region: region)
        self.organisation, self.name, self.id, self.xy = organisation, name, id, xy   # name must be set before id
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} id=#{id.inspect}>)
      end

      # For airports without an +id+, you may assign the two character region
      # (e.g. "LF") which will be combined with an 8 character digest of +name+.
      def id=(value)
        value = [value, [name].to_digest].join.upcase if value&.upcase&.match? AIXM::Feature::REGION_RE
        fail(ArgumentError, "invalid id") unless value&.upcase&.match? ID_RE
        @id = value.upcase
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def gps=(value)
        fail(ArgumentError, "invalid gps") unless value.nil? || value.is_a?(String)
        @gps = value&.upcase
      end

      # Type of airport.
      #
      # The type is usually derived from the presence of runways and helipads,
      # however, this may be overridden by setting an alternative value, most
      # notably +:landing_site+.
      #
      # @!attribute type
      # @overload type
      #   @return [Symbol] any of {TYPES}
      # @overload type=(value)
      #   @param value [Symbol] any of {TYPES}
      def type
        @type = case
          when @type then @type
          when runways.any? && (helipads.any? || fatos.any?) then :aerodrome_and_heliport
          when runways.any? then :aerodrome
          when helipads.any? || fatos.any? then :heliport
        end
      end

      def type=(value)
        resolved_value = TYPES.lookup(value&.to_s&.to_sym, nil)
        fail(ArgumentError, "invalid type") unless resolved_value == :landing_site
        @type = resolved_value
      end

      def xy=(value)
        fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
        @xy = value
      end

      def z=(value)
        fail(ArgumentError, "invalid z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
        @z = value
      end

      def declination=(value)
        return @declination = value if value.nil?
        fail(ArgumentError, "invalid declination") unless value.is_a?(Numeric) && (-180..180).include?(value)
        @declination = value.to_f + 0   # adding zero prevents -0.0
      end

      def transition_z=(value)
        fail(ArgumentError, "invalid transition_z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
        @transition_z = value
      end

      def operator=(value)
        fail(ArgumentError, "invalid name") unless value.nil? || value.is_a?(String)
        @operator = value&.uptrans
      end

      # @!visibility private
      def add_uid_to(builder, as: :AhpUid)
        builder.send(as, { region: (region if AIXM.ofmx?) }.compact) do |tag|
          tag.codeId(id)
        end
      end

      # @!visibility private
      def add_wrapped_uid_to(builder, as: :AhpUid, with:)
        builder.send(with) do |tag|
          add_uid_to(builder, as: as)
        end
      end

      # @!visibility private
      def add_to(builder)
        builder.comment "Airport: #{id} #{name}".dress
        builder.text "\n"
        builder.Ahp({ source: (source if AIXM.ofmx?) }.compact) do |ahp|
          ahp.comment(indented_comment) if comment
          add_uid_to(ahp)
          organisation.add_uid_to(ahp)
          ahp.txtName(name)
          ahp.codeIcao(id) if id.length == 4
          ahp.codeIata(id) if id.length == 3
          ahp.codeGps(gps) if AIXM.ofmx? && gps
          ahp.codeType(TYPES.key(type)) if type
          ahp.geoLat(xy.lat(AIXM.schema))
          ahp.geoLong(xy.long(AIXM.schema))
          ahp.codeDatum('WGE')
          if z
            ahp.valElev(z.alt)
            ahp.uomDistVer(z.unit.upcase)
          end
          ahp.valMagVar(declination) if declination
          ahp.txtNameAdmin(operator) if operator
          if transition_z
            ahp.valTransitionAlt(transition_z.alt)
            ahp.uomTransitionAlt(transition_z.unit.upcase)
          end
          timetable.add_to(ahp, as: :Aht) if timetable
          ahp.txtRmk(remarks) if remarks
        end
        runways.each do |runway|
          runway.add_to(builder)
        end
        fatos.each do |fato|
          fato.add_to(builder)
        end
        helipads.each do |helipad|
          helipad.add_to(builder)
        end
        if usage_limitations.any?
          builder.Ahu do |ahu|
            add_wrapped_uid_to(ahu, with: :AhuUid)
            usage_limitations.each do |usage_limitation|
              usage_limitation.add_to(ahu)
            end
          end
        end
        addresses.each.with_object({}) do |address, sequences|
          sequences[address.type] = (sequences[address.type] || 0) + 1
          address.add_to(builder, as: :Aha, sequence: sequences[address.type])
        end
        services.each do |service|
          builder.Sah do |sah|
            sah.SahUid do |sah_uid|
              add_uid_to(sah_uid)
              service.add_uid_to(sah_uid)
            end
          end
        end
      end

      # Limitations concerning the availability of an airport for certain flight
      # types, aircraft types etc during specific hours.
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
      #   airport.add_usage_limitation(type: :permitted)
      #
      # @example Limitation applying to specific traffic
      #   airport.add_usage_limitation(type: :reservation_required) do |reservation_required|
      #     reservation_required.add_condition do |condition|
      #       condition.aircraft = :glider
      #     end
      #     reservation_required.add_condition do |condition|
      #       condition.rule = :ifr
      #       condition.origin = :international
      #     end
      #     reservation_required.timetable = AIXM::H24
      #     reservation_required.remarks = "Reservation 24 HRS prior to arrival"
      #   end
      #
      # @see AIXM::Feature::Airport#add_usage_limitation
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#ahu-airport-usage
      class UsageLimitation
        include AIXM::Concerns::Association
        include AIXM::Concerns::XMLBuilder
        include AIXM::Concerns::Timetable
        include AIXM::Concerns::Remarks

        TYPES = {
          PERMIT: :permitted,
          FORBID: :forbidden,
          RESERV: :reservation_required,
          OTHER: :other                    # specify in remarks
        }.freeze

        # @!method conditions
        #   @return [Array<AIXM::Feature::Airport::UsageLimitation::Condition>] conditions for this limitation to apply
        #
        # @!method add_condition
        #   @yield [AIXM::Feature::Airport::UsageLimitation::Condition]
        #   @return [self]
        has_many :conditions, accept: 'AIXM::Feature::Airport::UsageLimitation::Condition' do |condition| end

        # @!method airport
        #   @return [AIXM::Feature::Airport] airport this usage limitation is assigned to
        belongs_to :airport

        # Type of limitation
        #
        # @overload type
        #   @return [Symbol] any of {TYPES}
        # @overload type=(value)
        #   @param value [Symbol] any of {TYPES}
        attr_reader :type

        # See the {cheat sheet}[AIXM::Feature::Airport::UsageLimitation] for
        #   examples on how to create instances of this class.
        def initialize(type:)
          self.type = type
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} type=#{type.inspect}>)
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        # @!visibility private
        def add_to(builder)
          builder.UsageLimitation do |usage_limitation|
            usage_limitation.codeUsageLimitation(TYPES.key(type))
            conditions.each do |condition|
              condition.add_to(usage_limitation)
            end
            timetable.add_to(usage_limitation, as: :Timetable) if timetable
            usage_limitation.txtRmk(remarks) if remarks
          end
        end

        # Flight and/or aircraft characteristics used to target a usage
        # limitation.
        #
        # @see AIXM::Feature::Airport#add_usage_limitation
        # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#ahu-airport-usage
        class Condition
          include AIXM::Concerns::Association
          include AIXM::Concerns::XMLBuilder

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
            CIVIL: :civilian,
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

          # @!method usage_limitation
          #   @return [AIXM::Feature::Airport::UsageLimitation] usage limitation the condition belongs to
          belongs_to :usage_limitation

          # Kind of aircraft.
          #
          # @overload aircraft
          #   @return [Symbol, nil] any of {AIRCRAFT}
          # @overload aircraft=(value)
          #   @param value [Symbol, nil] any of {AIRCRAFT}
          attr_reader :aircraft

          # Flight rule.
          #
          # @overload rule
          #   @return [Symbol, nil] any of {RULES}
          # @overload rule=(value)
          #   @param value [Symbol, nil] any of {RULES}
          attr_reader :rule

          # Military, civil etc.
          #
          # @overload realm
          #   @return [Symbol, nil] any of {REALMS}
          # @overload realm=(value)
          #   @param value [Symbol, nil] any of {REALMS}
          attr_reader :realm

          # Geographic origin of the flight.
          #
          # @overload origin
          #   @return [Symbol, nil] any of {ORIGINS}
          # @overload origin=(value)
          #   @param value [Symbol, nil] any of {ORIGINS}
          attr_reader :origin

          # Purpose of the flight.
          #
          # @overload purpose
          #   @return [Symbol, nil] any of {PURPOSES}
          # @overload purpose=(value)
          #   @param value [Symbol, nil] any of {PURPOSES}
          attr_reader :purpose

          # @return [String]
          def inspect
            %Q(#<#{self.class} aircraft=#{aircraft.inspect} rule=#{rule.inspect} realm=#{realm.inspect} origin=#{origin.inspect} purpose=#{purpose.inspect}>)
          end

          def aircraft=(value)
            @aircraft = value.nil? ? nil : AIRCRAFT.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid aircraft")
          end

          def rule=(value)
            @rule = value.nil? ? nil : RULES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid rule")
          end

          def realm=(value)
            @realm = value.nil? ? nil : REALMS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid realm")
          end

          def origin=(value)
            @origin = value.nil? ? nil : ORIGINS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid origin")
          end

          def purpose=(value)
            @purpose = value.nil? ? nil : PURPOSES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid purpose")
          end

          # @!visibility private
          def add_to(builder)
            builder.UsageCondition do |usage_condition|
              if aircraft
                usage_condition.AircraftClass do |aircraft_class|
                  aircraft_class.codeType(AIRCRAFT.key(aircraft))
                end
              end
              if rule || realm || origin || purpose
                usage_condition.FlightClass do |flight_class|
                  flight_class.codeRule(RULES.key(rule)) if rule
                  flight_class.codeMil(REALMS.key(realm)) if realm
                  flight_class.codeOrigin(ORIGINS.key(origin)) if origin
                  flight_class.codePurpose(PURPOSES.key(purpose)) if purpose
                end
              end
            end
          end
        end
      end
    end
  end
end
