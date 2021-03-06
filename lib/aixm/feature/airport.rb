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
    #   airport.type = TYPES
    #   airport.z = AIXM.z or nil
    #   airport.declination = Float or nil
    #   airport.transition_z = AIXM.z or nil
    #   airport.timetable = AIXM.timetable or nil
    #   airport.operator = String or nil
    #   airport.remarks = String or nil
    #   airport.add_runway(AIXM.runway)
    #   airport.add_fato(AIXM.fato)
    #   airport.add_helipad(AIXM.helipad)
    #   airport.add_usage_limitation(UsageLimitation::TYPES)
    #   airport.add_address(AIXM.address)
    #
    # For airports without an +id+, you may assign the two character region
    # (e.g. "LF") which will be combined with an 8 character digest of +name+.
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#ahp-airport
    class Airport < Feature
      include AIXM::Association
      include AIXM::Memoize

      public_class_method :new

      ID_RE = /^([A-Z]{3,4}|[A-Z]{2}[A-Z\d]{4,})$/.freeze

      TYPES = {
        AD: :aerodrome,
        HP: :heliport,
        AH: :aerodrome_and_heliport,
        LS: :landing_site
      }.freeze

      # @!method addresses
      #   @return [Array<AIXM::Feature::Address>] postal address, url, A/A or A/G frequency etc
      # @!method add_address(address)
      #   @param address [AIXM::Feature::Address]
      #   @return [self]
      has_many :addresses, as: :addressable

      # @!method fatos
      #   @return [Array<AIXM::Component::FATO>] FATOs present at this airport
      # @!method add_fato(fato)
      #   @param fato [AIXM::Component::FATO]
      has_many :fatos

      # @!method helipads
      #   @return [Array<AIXM::Component::Helipad>] helipads present at this airport
      # @!method add_helipad(helipad)
      #   @param helipad [AIXM::Component::Helipad]
      has_many :helipads

      # @!method runways
      #   @return [Array<AIXM::Component::Runway>] runways present at this airport
      # @!method add_runway(runway)
      #   @param runway [AIXM::Component::Runway]
      has_many :runways

      # @!method usage_limitations
      #   @return [Array<AIXM::Feature::Airport::UsageLimitation>] usage limitations
      # @!method add_usage_limitation
      #   @yield [AIXM::Feature::Airport::UsageLimitation]
      #   @return [self]
      has_many :usage_limitations, accept: 'AIXM::Feature::Airport::UsageLimitation' do |usage_limitation, type:| end

      # @!method designated_points
      #   @return [Array<AIXM::Feature::NavigationalAid::DesignatedPoint>] designated points
      # @!method add_designated_point(designated_point)
      #   @param designated_point [AIXM::Feature::NavigationalAid::DesignatedPoint]
      has_many :designated_points

      # @!method units
      #   @return [Array<AIXM::Feature::Unit>] units
      # @!method add_unit(unit)
      #   @param unit [AIXM::Feature::Unit]
      has_many :units

      # @!method organisation
      #   @return [AIXM::Feature::Organisation] superior organisation
      belongs_to :organisation, as: :member

      # ICAO indicator, IATA indicator or generated indicator
      #
      # * four letter ICAO indicator (e.g. "LFMV")
      # * three letter IATA indicator (e.g. "AVN")
      # * two letter ICAO country code + four digit number (e.g. "LF1234")
      # * two letter ICAO country code + at least four letters/digits (e.g.
      #   "LFFOOBAR123" or "LF" + GPS code)
      #
      # @return [String] airport indicator
      attr_reader :id

      # @return [String] full name
      attr_reader :name

      # @return [AIXM::XY] reference point
      attr_reader :xy

      # @return [String, nil] GPS code
      attr_reader :gps

      # @return [AIXM::Z, nil] elevation in +:qnh+
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

      # @return [AIXM::Z, nil] transition altitude in +:qnh+
      attr_reader :transition_z

      # @return [AIXM::Component::Timetable, nil] operating hours
      attr_reader :timetable

      # @return [String, nil] operator of the airport
      attr_reader :operator

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(source: nil, region: nil, organisation:, id: nil, name:, xy:)
        super(source: source, region: region)
        self.organisation, self.name, self.xy = organisation, name, xy
        self.id = id   # name must already be set
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

      # The type is usually derived from the presence of runways and helipads,
      # however, this may be overridden by setting an alternative value, most
      # notably +:landing_site+.
      #
      # @!attribute type
      # @return [Symbol] type of airport (see {TYPES})
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

      def timetable=(value)
        fail(ArgumentError, "invalid timetable") unless value.nil? || value.is_a?(AIXM::Component::Timetable)
        @timetable = value
      end

      def operator=(value)
        fail(ArgumentError, "invalid name") unless value.nil? || value.is_a?(String)
        @operator = value&.uptrans
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] UID markup
      def to_uid(as: :AhpUid)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as, ({ region: (region if AIXM.ofmx?) }.compact)) do |tag|
          tag.codeId(id)
        end
      end
      memoize :to_uid

      # @return [String] UID markup
      def to_wrapped_uid(as: :AhpUid, with:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(with) do |tag|
          tag << to_uid(as: as).indent(2)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Airport: #{id} #{name}"
        builder.Ahp({ source: (source if AIXM.ofmx?) }.compact) do |ahp|
          ahp << to_uid.indent(2)
          ahp << organisation.to_uid.indent(2)
          ahp.txtName(name)
          ahp.codeIcao(id) if id.length == 4
          ahp.codeIata(id) if id.length == 3
          ahp.codeGps(gps) if AIXM.ofmx? && gps
          ahp.codeType(TYPES.key(type).to_s) if type
          ahp.geoLat(xy.lat(AIXM.schema))
          ahp.geoLong(xy.long(AIXM.schema))
          ahp.codeDatum('WGE')
          if z
            ahp.valElev(z.alt)
            ahp.uomDistVer(z.unit.upcase.to_s)
          end
          ahp.valMagVar(declination) if declination
          ahp.txtNameAdmin(operator) if operator
          if transition_z
            ahp.valTransitionAlt(transition_z.alt)
            ahp.uomTransitionAlt(transition_z.unit.upcase.to_s)
          end
          ahp << timetable.to_xml(as: :Aht).indent(2) if timetable
          ahp.txtRmk(remarks) if remarks
        end
        runways.each do |runway|
          builder << runway.to_xml
        end
        fatos.each do |fato|
          builder << fato.to_xml
        end
        helipads.each do |helipad|
          builder << helipad.to_xml
        end
        if usage_limitations.any?
          builder.Ahu do |ahu|
            ahu << to_wrapped_uid(with: :AhuUid).indent(2)
            usage_limitations.each do |usage_limitation|
              ahu << usage_limitation.to_xml.indent(2)
            end
          end
        end
        addresses.each.with_object({}) do |address, sequences|
          sequences[address.type] = (sequences[address.type] || 0) + 1
          builder << address.to_xml(as: :Aha, sequence: sequences[address.type])
        end
        builder.target!
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
        include AIXM::Association

        TYPES = {
          PERMIT: :permitted,
          FORBID: :forbidden,
          RESERV: :reservation_required,
          OTHER: :other                    # specify in remarks
        }.freeze

        # @!method conditions
        #   @return [Array<AIXM::Feature::Airport::UsageLimitation::Condition>] conditions for this limitation to apply
        # @!method add_condition
        #   @yield [AIXM::Feature::Airport::UsageLimitation::Condition]
        #   @return [self]
        has_many :conditions, accept: 'AIXM::Feature::Airport::UsageLimitation::Condition' do |condition| end

        # @!method airport
        #   @return [AIXM::Feature::Airport] airport this usage limitation is assigned to
        belongs_to :airport

        # @return [Symbol] type of limitation
        attr_reader :type

        # @return [AIXM::Component::Timetable, nil] limitation application hours
        attr_reader :timetable

        # @return [String, nil] free text remarks
        attr_reader :remarks

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

        def timetable=(value)
          fail(ArgumentError, "invalid timetable") unless value.nil? || value.is_a?(AIXM::Component::Timetable)
          @timetable = value
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
            usage_limitation << timetable.to_xml(as: :Timetable).indent(2) if timetable
            usage_limitation.txtRmk(remarks) if remarks
          end
        end

        # Flight and/or aircraft characteristics used to target a usage
        # limitation.
        #
        # @see AIXM::Feature::Airport#add_usage_limitation
        # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#ahu-airport-usage
        class Condition
          include AIXM::Association

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

          # @return [Symbol, nil] kind of aircraft (see {AIRCRAFT})
          attr_reader :aircraft

          # @return [String, nil] flight rule (see {RULES})
          attr_reader :rule

          # @return [String, nil] whether military or civil (see {REALMS})
          attr_reader :realm

          # @return [String, nil] geographic origin of the flight (see {ORIGINS})
          attr_reader :origin

          # @return [String, nil] purpose of the flight (see {PURPOSES})
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
