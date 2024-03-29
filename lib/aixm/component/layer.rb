using AIXM::Refinements

module AIXM
  class Component

    # Each airspace has one or more layers with optional airspace class and
    # mandatory vertical limit.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   layer = AIXM.layer(
    #     class: String or nil
    #     location_indicator: String or nil
    #     vertical_limit: AIXM.vertical_limit
    #   )
    #   layer.activity = String or nil
    #   layer.timetable = AIXM.timetable or nil
    #   layer.selective = true or false (default)
    #   layer.remarks = String or nil
    #   layer.add_service(AIXM.service)
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airspace
    class Layer < Component
      include AIXM::Concerns::Association
      include AIXM::Concerns::Timetable
      include AIXM::Concerns::Remarks

      CLASSES = (:A..:G).freeze

      ACTIVITIES = {
        ACCIDENT: :accident_investigation,
        ACROBAT: :acrobatics,
        AIRGUN: :aerial_gunnery,
        AIRMODEL: :aeromodelling,
        AIRSHOW: :air_show,
        ANTIHAIL: :anti_hail_rocket,
        ARTILERY: :artillary_firing,
        ASCENT: :probe,
        ATS: :air_traffic_services,
        BALLOON: :balloon,
        BIRD: :bird_hazard,
        'BIRD-MGR': :bird_migration,
        BLAST: :blasting_operation,
        DROP: :dropping,
        DUSTING: :crop_dusting,
        EQUIPMENT: :special_equipment_required,
        'EQUIPMENT-833': :radio_8_33_required,
        'EQUIPMENT-RNAV': :rnav_equipment_required,
        'EQUIPMENT-RSVM': :rsvm_equipment_required,
        EXERCISE: :combat_exercise,
        FAUNA: :sensitive_fauna,
        FIRE: :fire_suppression,
        FIREWORK: :fireworks,
        GAZ: :gaz_field,
        GLIDER: :gliding,
        HANGGLIDER: :hanggliding,
        'HI-LIGHT': :high_intensity_light,
        'HI-RADIO': :high_intensity_radio,
        'IND-CHEM': :chemical_plant,
        'IND-NUCLEAR': :nuclear_activity,
        'IND-OIL': :oil_refinery,
        JETCLIMB: :jet_climb,
        LASER: :laser_light,
        MILOPS: :military_operation,
        MISSILES: :guided_missiles,
        NATURE: :natural_reserve,
        NAVAL: :ship_exercise,
        'NO-NOISE': :noise_abatement,
        OIL: :oil_field,
        PARACHUTE: :parachuting,
        PARAGLIDER: :paragliding,
        POPULATION: :highly_populated,
        PROCEDURE: :special_procedure,
        REFUEL: :refuelling,
        SHOOT: :shooting_from_ground,
        SPACEFLT: :space_flight,
        SPORT: :sport,
        TECHNICAL:  :technical_activity,
        'TFC-AD': :aerodrome_traffic,
        'TFC-HELI': :helicopter_traffic,
        TOWING: :towing_traffic,
        TRG: :training,
        UAV: :drone,
        ULM: :ultra_light_flight,
        VIP: :vip,
        'VIP-PRES': :president,
        'VIP-VICE': :vice_president,
        WATERBLAST: :underwater_explosion,
        WINCH: :glider_winch,
        WORK: :aerial_work,
        OTHER: :other
      }.freeze

      # @!method vertical_limit
      #   @return [AIXM::Component::VerticalLimit] vertical limit of this layer
      #
      # @!method vertical_limit=(vertical_limit)
      #   @param vertical_limit [AIXM::Component::VerticalLimit]
      has_one :vertical_limit

      # @!method services
      #   @return [Array<AIXM::Component::Service>] services
      #
      # @!method add_service(service)
      #   @param service [AIXM::Component::Service]
      has_many :services

      # @!method airspace
      #   @return [AIXM::Feature::Airspace] airspace the layer defines
      belongs_to :airspace

      # Four letter location identifier as published in the ICAO DOC 7910
      #
      # @overload location_indicator
      #   @return [String, nil]
      # @overload location_indicator=(value)
      #   @param value [String, nil]
      attr_reader :location_indicator

      # Primary activity
      #
      # @overload activity
      #   @return [Symbol, nil] any of {ACTIVITIES}
      # @overload activity=(value)
      #   @param value [Symbol, nil] any of {ACTIVITIES}
      attr_reader :activity

      # See the {cheat sheet}[AIXM::Component::Layer] for examples on how to
      # create instances of this class.
      def initialize(class: nil, location_indicator: nil, vertical_limit:)
        self.class = binding.local_variable_get(:class)
        self.location_indicator, self.vertical_limit = location_indicator, vertical_limit
        self.selective = false
      end

      # @return [String]
      def inspect
        %Q(#<#{__class__} class=#{@klass.inspect}>)
      end

      # Class of layer.
      #
      # @note Use +Object#__class__+ alias to query the Ruby object class.
      #
      # @!attribute class
      # @overload class
      #   @return [Symbol] any of {CLASSES}
      # @overload class=(value)
      #   @param value [Symbol] any of {CLASSES}
      def class
        @klass
      end

      def class=(value)
        @klass = value&.to_sym&.upcase
        fail(ArgumentError, "invalid class") unless @klass.nil? || CLASSES.include?(@klass)
      end

      def location_indicator=(value)
        fail(ArgumentError, "invalid location indicator") unless value.nil? || (value.is_a?(String) && value.length == 4)
        @location_indicator = value&.uptrans
      end

      def activity=(value)
        @activity = value.nil? ? nil : ACTIVITIES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid activity")
      end

      # Whether the layer may be activated selectively.
      #
      # @!attribute selective
      # @overload selective?
      #   @return [Boolean]
      # @overload selective=(value)
      #   @param value [Boolean]
      def selective?
        @selective
      end

      def selective=(value)
        fail(ArgumentError, "invalid selective") unless [true, false].include? value
        @selective = value
      end

      # @!visibility private
      def add_to(builder)
        builder.codeClass(self.class) if self.class
        builder.codeLocInd(location_indicator) if location_indicator
        if activity
          builder.codeActivity(ACTIVITIES.key(activity).to_s.then_if(AIXM.aixm?) { { 'AIRMODEL' => 'UAV', 'WINCH' => 'GLIDER' }[_1] || _1 })
        end
        vertical_limit.add_to(builder)
        timetable.add_to(builder, as: :Att) if timetable
        builder.codeSelAvbl(selective? ? 'Y' : 'N') if AIXM.ofmx?
        builder.txtRmk(remarks) if remarks
      end
    end

  end
end
