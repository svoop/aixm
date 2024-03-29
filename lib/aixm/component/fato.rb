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
    #   fato.dimensions = AIXM.r or nil
    #   fato.surface = AIXM.surface
    #   fato.marking = String or nil
    #   fato.profile = String or nil
    #   fato.status = STATUSES or nil
    #   fato.remarks = String or nil
    #   fato.add_direction(
    #     name: String
    #   ) do |direction|
    #     direction.geographic_bearing = AIXM.a or nil
    #     direction.vasis = AIXM.vasis or nil (default: unspecified VASIS)
    #     fato.add_lighting = AIXM.lighting
    #     fato.add_approach_lighting = AIXM.approach_lighting
    #     direction.remarks = String or nil
    #   end
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#fto-fato
    class FATO < Component
      include AIXM::Concerns::Association
      include AIXM::Concerns::Marking
      include AIXM::Concerns::Remarks

      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,          # e.g. construction work
        PARKED: :parked_aircraft,        # parked or disabled aircraft on FATO
        FAILAID: :visual_aids_failure,   # failure or irregular operation of visual aids
        SPOWER: :secondary_power,        # secondary power supply in operation
        OTHER: :other                    # specify in remarks
      }.freeze

      # @!method surface
      #   @return [AIXM::Component::Surface] surface of the FATO
      #
      # @!method surface=(surface)
      #   @param surface [AIXM::Component::Surface]
      has_one :surface

      # @!method directions
      #   @return [Array<AIXM::Component::FATO::Direction>] maps added direction names to full FATO directions
      #
      # @!method add_direction(direction)
      #   @param direction [AIXM::A] name of the FATO direction (e.g. "12" or "16L")
      #   @return [self]
      has_many :directions, accept: 'AIXM::Component::FATO::Direction' do |direction, name:| end

      # @!method airport
      #   @return [AIXM::Feature::Airport] airport this FATO belongs to
      belongs_to :airport

      # @!method helipad
      #   @return [AIXM::Component::Helipad] helipad situated on this FATO
      belongs_to :helipad

      # Full name (e.g. "H1")
      #
      # @overload name
      #   @return [String]
      # @overload name=(value)
      #   @param value [String]
      attr_reader :name

      # Dimensions
      #
      # @overload dimensions
      #   @return [AIXM::R, nil]
      # @overload dimensions=(value)
      #   @param value [AIXM::R, nil]
      attr_reader :dimensions

      # Profile description
      #
      # @overload profile
      #   @return [String, nil]
      # @overload profile=(value)
      #   @param value [String, nil]
      attr_reader :profile

      # Status of the FATO
      #
      # @overload status
      #   @return [Symbol, nil] any of {STATUSES} or +nil+ for normal operation
      # @overload status=(value)
      #   @param value [Symbol, nil] any of {STATUSES} or +nil+ for normal
      #     operation
      attr_reader :status

      # See the {cheat sheet}[AIXM::Component::FATO] for examples on how to
      # create instances of this class.
      def initialize(name:)
        self.name = name
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

      def dimensions=(value)
        fail(ArgumentError, "invalid dimensions") unless value.nil? || value.is_a?(AIXM::R)
        @dimensions = value
      end

      def profile=(value)
        @profile = value&.to_s
      end

      def status=(value)
        @status = value.nil? ? nil : (STATUSES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid status"))
      end

      # @!visibility private
      def add_uid_to(builder)
        builder.FtoUid do |fto_uid|
          airport.add_uid_to(fto_uid)
          fto_uid.txtDesig(name)
        end
      end

      # @!visibility private
      def add_to(builder)
        builder.Fto do |fto|
          add_uid_to(fto)
          if dimensions
            fto.valLen(dimensions.length.to_m.dim.trim)
            fto.valWid(dimensions.width.to_m.dim.trim)
            fto.uomDim('M')
          end
          surface.add_to(fto) if surface
          fto.txtProfile(profile) if profile
          fto.txtMarking(marking) if marking
          fto.codeSts(STATUSES.key(status)) if status
          fto.txtRmk(remarks) if remarks
        end
        directions.each do |direction|
          direction.add_to(builder)
        end
      end

      # FATO directions further describe each direction to and from the FATO.
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#fdn-fato-direction
      class Direction
        include AIXM::Concerns::Association
        include AIXM::Concerns::Memoize
        include AIXM::Concerns::XMLBuilder
        include AIXM::Concerns::Remarks

        # @!method lightings
        #   @return [Array<AIXM::Component::Lighting>] installed lighting systems
        #
        # @!method add_lighting(lighting)
        #   @param lighting [AIXM::Component::Lighting]
        has_many :lightings, as: :lightable

        # @!method approach_lightings
        #   @return [Array<AIXM::Component::ApproachLighting>] installed approach lighting systems
        #
        # @!method add_approach_lighting(approach_lighting)
        #   @param approach_lighting [AIXM::Component::ApproachLighting]
        #   @return [self]
        has_many :approach_lightings, as: :approach_lightable

        # @!method fato
        #   @return [AIXM::Component::FATO] FATO the FATO direction is further describing
        belongs_to :fato

        # Name of the FATO direction (e.g. "12" or "16L")
        #
        # @overload name
        #   @return [AIXM::A]
        # @overload name=(value)
        #   @param value [AIXM::A]
        attr_reader :name

        # @return [AIXM::A, nil] (true) geographic bearing in degrees
        attr_reader :geographic_bearing

        # @return [AIXM::Component::VASIS, nil] visual approach slope indicator
        #   system
        attr_reader :vasis

        # See the {cheat sheet}[AIXM::Component::FATO] for examples on how to
        #   create instances of this class.
        def initialize(name:)
          self.name = name
          self.vasis = AIXM.vasis
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} airport=#{fato&.airport&.id.inspect} name=#{name.to_s(:runway).inspect}>)
        end

        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? String
          @name = AIXM.a(value)
        end

        def geographic_bearing=(value)
          return @geographic_bearing = nil if value.nil?
          fail(ArgumentError, "invalid geographic bearing") unless value.is_a? AIXM::A
          @geographic_bearing = value
        end

        # @return [AIXM::A] magnetic bearing in degrees
        def magnetic_bearing
          if geographic_bearing && fato.airport.declination
            geographic_bearing - fato.airport.declination
          end
        end

        def vasis=(value)
          fail(ArgumentError, "invalid vasis") unless value.nil? || value.is_a?(AIXM::Component::VASIS)
          @vasis = value
        end

        # @!visibility private
        def add_uid_to(builder)
          builder.FdnUid do |fdn_uid|
            fato.add_uid_to(fdn_uid)
            fdn_uid.txtDesig(name.to_s(:runway))
          end
        end

        # @!visibility private
        def add_to(builder)
          builder.Fdn do |fdn|
            add_uid_to(fdn)
            fdn.valTrueBrg(geographic_bearing.to_s(:bearing)) if geographic_bearing
            fdn.valMagBrg(magnetic_bearing.to_s(:bearing)) if magnetic_bearing
            vasis.add_to(fdn) if vasis
            fdn.txtRmk(remarks) if remarks
          end
          lightings.each do |lighting|
            lighting.add_to(builder, as: :Fls)
          end
          approach_lightings.each do |approach_lighting|
            approach_lighting.add_to(builder, as: :Fda)
          end
        end
      end
    end
  end
end
