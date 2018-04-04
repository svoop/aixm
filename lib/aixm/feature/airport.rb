using AIXM::Refinements

module AIXM
  module Feature

    ##
    # Airport feature (aerodrome, heliport etc)
    #
    # Arguments:
    # * +code+ - airport code
    class Airport < Base
      CODE_PATTERN = /^[A-Z]{2}([A-Z]{1,2}|\d{4})$/.freeze

      TYPES = {
        AD: :aerodrome,
        HP: :heliport,
        AH: :aerodrome_and_heliport,
        LS: :landing_site
      }

      attr_reader :organisation, :code, :name, :xy
      attr_reader :gps, :z, :declination, :transition_z, :schedule, :remarks
      attr_accessor :runways, :helipads, :usage_limitations

      public_class_method :new

      def initialize(source: nil, region: nil, organisation:, code:, name:, xy:)
        super(source: source, region: region)
        self.organisation, self.code, self.name, self.xy = organisation, code, name, xy
        @runways, @helipads, @usage_limitations = [], [], []
      end

      def inspect
        %Q(#<#{self.class} code=#{code.inspect}>)
      end

      def organisation=(value)
        fail(ArgumentError, "invalid organisation") unless value.is_a? AIXM::Feature::Organisation
        @organisation = value
      end

      ##
      # Airport code
      #
      # Either (in order of preference):
      # * four letter ICAO indicator (e.g. "LFMV")
      # * three letter IATA indicator (e.g. "AVN")
      # * two letter ICAO country code + four digit number (e.g. "LF1234")
      def code=(value)
        fail(ArgumentError, "invalid code `#{code}'") unless value.upcase.match? CODE_PATTERN
        @code = value.upcase
      end

      ##
      # Full name
      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      ##
      # GPS Code
      def gps=(value)
        fail(ArgumentError, "invalid gps") unless value.nil? || value.is_a?(String)
        @gps = value&.upcase
      end

      ##
      # Type of airport
      #
      # The type is usually derived from the presence of runways and helipads,
      # however, this may be overridden by setting an alternative value.
      #
      # Allowed values:
      # * +:landing_site+ (+:LS+)
      def type=(value)
        resolved_value = TYPES.lookup(value&.to_sym, nil)
        fail(ArgumentError, "invalid type") unless resolved_value == :landing_site
        @type = resolved_value
      end

      def type
        @type = case
          when @type then @type
          when runways.any? && helipads.any? then :aerodrome_and_heliport
          when runways.any? then :aerodrome
          when helipads.any? then :heliport
        end
      end

      ##
      # Reference point
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
      # Magnetic declination in degrees
      #
      # When looking towards the geographic (aka: true) north, a positive
      # declination represents the magnetic north is to the right (aka: east)
      # by this angle.
      #
      # https://en.wikipedia.org/wiki/Magnetic_declination
      def declination=(value)
        fail(ArgumentError, "invalid declination") unless value.respond_to? :to_f
        @declination = value
        fail(ArgumentError, "invalid declination") unless (-180..180).include?(@declination)
      end

      ##
      # Transition altitude in +qnh+
      def transition_z=(value)
        fail(ArgumentError, "invalid transition_z") unless value.is_a?(AIXM::Z) && value.qnh?
        @transition_z = value
      end

      ##
      # Schedule as instance of +AIXM::Component::Schedule+
      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      ##
      # Free text remarks
      def remarks=(value)
        @remarks = value&.to_s
      end

      ##
      # Add a runway to the airport
      def add_runway(runway)
        fail(ArgumentError, "invalid runway") unless runway.is_a? AIXM::Component::Runway
        runway.send(:airport=, self)
        @runways << runway
      end

      ##
      # Add a helipad to the airport
      def add_helipad(helipad)
        fail(ArgumentError, "invalid helipad") unless helipad.is_a? AIXM::Component::Helipad
        helipad.send(:airport=, self)
        @helipads << helipad
      end

      ##
      # Add usage limitations
      #
      # Allowed values:
      # * +:permitted+
      # * +:forbidden+
      # * +:reservation_required+ - specify in +remarks+
      # * +:other+ - specify in +remarks+
      #
      # Example applying to any traffic:
      #   airport.add_usage_limitation(:permitted)
      #
      # Example applying to specific traffic:
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
      def add_usage_limitation(limitation)
        usage_limitation = UsageLimitation.new(limitation: limitation)
        yield(usage_limitation) if block_given?
        @usage_limitations << usage_limitation
        self
      end

      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.AhpUid({ region: (region if AIXM.ofmx?) }.compact) do |ahp_uid|
          ahp_uid.codeId(code)
        end
      end

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

      class UsageLimitation
        LIMITATIONS = {
          PERMIT: :permitted,
          FORBID: :forbidden,
          RESERV: :reservation_required,
          OTHER: :other
        }.freeze

        attr_reader :airport
        attr_reader :limitation
        attr_reader :conditions, :schedule, :remarks

        def initialize(limitation:)
          self.limitation = limitation
          @conditions = []
        end

        def inspect
          %Q(#<#{self.class} limitation=#{limitation.inspect}>)
        end

        def limitation=(value)
          @limitation = LIMITATIONS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid limitation")
        end

        def add_condition()
          condition = Condition.new
          yield(condition)
          @conditions << condition
          self
        end

        ##
        # Schedule as instance of +AIXM::Component::Schedule+
        def schedule=(value)
          fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
          @schedule = value
        end

        ##
        # Free text remarks
        def remarks=(value)
          @remarks = value&.to_s
        end

        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.UsageLimitation do |usage_limitation|
            usage_limitation.codeUsageLimitation(LIMITATIONS.key(limitation).to_s)
            conditions.each do |condition|
              usage_limitation << condition.to_xml.indent(2)
            end
            usage_limitation << schedule.to_xml(as: :Timetable).indent(2) if schedule
            usage_limitation.txtRmk(remarks) if remarks
          end
        end

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
            OTHER: :other
          }.freeze

          RULES = {
            I: :ifr,
            V: :vfr,
            IV: :ifr_and_vfr
          }.freeze

          REALMS = {
            CIVIL: :civil,
            MIL: :military,
            OTHER: :other
          }.freeze

          ORIGINS = {
            NTL: :national,
            INTL: :international,
            ANY: :any,
            OTHER: :other
          }.freeze

          PURPOSES = {
            S: :scheduled,
            NS: :not_scheduled,
            P: :private,
            TRG: :school_or_training,
            WORK: :aerial_work,
            OTHER: :other
          }.freeze

          attr_reader :aircraft, :rule, :realm, :origin, :purpose

          def inspect
            %Q(#<#{self.class} aircraft=#{aircraft.inspect} rule=#{rule.inspect} realm=#{realm.inspect} origin=#{origin.inspect} purpose=#{purpose.inspect}>)
          end

          ##
          # Condition by aircraft
          #
          # Allowed values:
          # * +:landplane+ (+:L+)
          # * +:seaplane+ (+:S+)
          # * +:amphibian+ (+:A+)
          # * +:helicopter+ (+:H+)
          # * +:gyrocopter+ (+:G+)
          # * +:tilt_wing+ (+:T+)
          # * +:short_takeoff_and_landing+ (+:R+)
          # * +:glider+ (+:E+)
          # * +:hangglider+ (+:H+)
          # * +:paraglider+ (+:P+)
          # * +:ultra_light+ (+:U+)
          # * +:balloon+ (+:B+)
          # * +:unmanned_drone+ (+:D+)
          # * +:other+  (+:OTHER+) - specify in +remarks+
          def aircraft=(value)
            @aircraft = AIRCRAFT.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid aircraft")
          end

          ##
          # Condition by flight rule
          #
          # Allowed values:
          # * +:ifr+ (+:I+)
          # * +:vfr+ (+:V+)
          # * +:ifr_and_vfr+ (+:IV+)
          def rule=(value)
            @rule = RULES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid rule")
          end

          ##
          # Condition by realm
          #
          # Allowed values:
          # * +:civil+ (+:CIVIL+)
          # * +:military+ (+:MIL+)
          # * +:other+ (+:OTHER+) - specify in +remarks+
          def realm=(value)
            @realm = REALMS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid realm")
          end

          ##
          # Condition by origin
          #
          # Allowed values:
          # * +:national+ (+:NTL+)
          # * +:international+ (+:INTL+)
          # * +:any+ (+:ANY+)
          # * +:other+ (+:OTHER+) - specify in +remarks+
          def origin=(value)
            @origin = ORIGINS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid origin")
          end

          ##
          # Condition by purpose
          #
          # Allowed values:
          # * +:scheduled+ (+:S+)
          # * +:not_scheduled+ (+:NS+)
          # * +:private+ (+:P+)
          # * +:school_or_training+ (+:TRG+)
          # * +:aerial_work+ (+:WORK+)
          # * +:other+ (+:OTHER+) - specify in +remarks+
          def purpose=(value)
            @purpose = PURPOSES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid purpose")
          end

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
