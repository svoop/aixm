using AIXM::Refinements

module AIXM
  module Feature

    ##
    # Airport feature (aerodrome, heliport etc)
    #
    # The +code+ is either and in order of preference:
    # * four letter ICAO indicator (e.g. "LFMV")
    # * three letter IATA indicator (e.g. "AVN")
    # * two letter country code + four digit number (e.g. "LF1234")
    class Airport
      attr_reader :code
      attr_reader :name, :xy, :z, :declination, :remarks
      attr_accessor :runways, :helipads, :usage_limitations

      CODE_PATTERN = /^[A-Z]{2}([A-Z]{1,2}|\d{4})$/.freeze

      def initialize(code:)
        @code = code.upcase
        fail(ArgumentError, "illegal code `#{code}'") unless @code =~ CODE_PATTERN
        @runways, @helipads, @usage_limitations = [], [], []
      end

      def inspect
        %Q(#<AIXM::Feature::Airport code=#{code.inspect}>)
      end

      ##
      # Full name
      def name=(value)
        fail(ArgumentError, "illegal name") unless value.is_a? String
        @name = value.uptrans
      end

      ##
      # Reference point
      def xy=(value)
        fail(ArgumentError, "illegal xy") unless value.is_a? AIXM::XY
        @xy = value
      end

      ##
      # Elevation in QNH
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
        fail(ArgumentError, "illegal declination") unless value.is_a?(Float) && (-180..180).include?(value)
        @declination = value
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
        usage_limitation = UsageLimitation.new(airport: self, limitation: limitation)
        yield(usage_limitation) if block_given?
        @usage_limitations << usage_limitation
        self
      end

      ##
      # Free text with further details
      def remarks=(value)
        @remarks = value&.to_s
      end

      class UsageLimitation
        LIMITATIONS = {
          PERMIT: :permitted,
          FORBID: :forbidden,
          RESERV: :reservation_required,
          OTHER: :other
        }.freeze

        attr_reader :airport
        attr_reader :limitation, :conditions, :schedule, :remarks

        def initialize(airport:, limitation:)
          fail(ArgumentError, "illegal airport") unless airport.is_a? AIXM::Feature::Airport
          @airport = airport
          @limitation = LIMITATIONS.lookup(limitation&.to_sym, nil) || fail(ArgumentError, "invalid limitation")
          @conditions = []
        end

        def inspect
          %Q(#<AIXM::Feature::Airport::UsageLimitation limitation=#{limitation.inspect}>)
        end

        ##
        # Add a usage limitation condition
        #
        # See +AIXM::Feature::Airport#add_usage_limitation+ for examples
        def add_condition()
          condition = Condition.new(usage_limitation: self)
          yield(condition)
          @conditions << condition
          self
        end

        ##
        # Assign a +AIXM::Component::Schedule+
        def schedule=(value)
          fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
          @schedule = value
        end

        ##
        # Free text with further details
        def remarks=(value)
          @remarks = value&.to_s
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

          attr_reader :usage_limitation
          attr_reader :aircraft, :rule, :realm, :origin, :purpose

          def initialize(usage_limitation:)
            fail(ArgumentError, "illegal usage limitation") unless usage_limitation.is_a? AIXM::Feature::Airport::UsageLimitation
            @usage_limitation = usage_limitation
          end

          def inspect
            %Q(#<AIXM::Feature::Airport::UsageLimitation::Condition aircraft=#{aircraft.inspect} rule=#{rule.inspect} realm=#{realm.inspect} origin=#{origin.inspect} purpose=#{purpose.inspect}>)
          end

          ##
          # Condition by aircraft
          #
          # Allowed values:
          # * +:landplane+
          # * +:seaplane+
          # * +:amphibian+
          # * +:helicopter+
          # * +:gyrocopter+
          # * +:tilt_wing+
          # * +:short_takeoff_and_landing+
          # * +:glider+
          # * +:hangglider+
          # * +:paraglider+
          # * +:ultra_light+
          # * +:balloon+
          # * +:unmanned_drone+
          # * +:other+ - specified in +remarks+
          def aircraft=(value)
            @aircraft = AIRCRAFT.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid aircraft")
          end

          ##
          # Condition by flight rule
          #
          # Allowed values:
          # * +:ifr+
          # * +:vfr+
          # * +:ifr_and_vfr+
          def rule=(value)
            @rule = RULES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid rule")
          end

          ##
          # Condition by realm
          #
          # Allowed values:
          # * +:civil+
          # * +:military+
          # * +:other+ - specified in +remarks+
          def realm=(value)
            @realm = REALMS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid realm")
          end

          ##
          # Condition by origin
          #
          # Allowed values:
          # * +:national+
          # * +:international+
          # * +:any+
          # * +:other+ - specified in +remarks+
          def origin=(value)
            @origin = ORIGINS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid origin")
          end

          ##
          # Condition by purpose
          #
          # Allowed values:
          # * +:scheduled+
          # * +:not_scheduled+
          # * +:private+
          # * +:school_or_training+
          # * +:aerial_work+
          # * +:other+ - specified in +remarks+
          def purpose=(value)
            @purpose = PURPOSES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid purpose")
          end
        end
      end
    end
  end
end
