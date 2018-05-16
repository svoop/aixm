using AIXM::Refinements

module AIXM
  class Component

    # Each airspace has one or more layers with optional airspace class and
    # mandatory vertical limits.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   layer = AIXM.layer(
    #     class: String or nil
    #     vertical_limits: AIXM.vertical_limits
    #   )
    #   layer.activity = String or nil
    #   layer.timetable = AIXM.timetable or nil
    #   layer.selective = true or false (default)
    #   layer.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airspace
    class Layer
      CLASSES = (:A..:G).freeze

      ACTIVITIES = {
        ACCIDENT: :accident_investigation,
        ACROBAT: :acrobatics,
        AIRGUN: :aerial_gunnery,
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
        TOWING: :winch_activity,
        TRG: :training,
        UAV: :drone,
        ULM: :ultra_light_flight,
        VIP: :vip,
        'VIP-PRES': :president,
        'VIP-VICE': :vice_president,
        WATERBLAST: :underwater_explosion,
        WORK: :aerial_work,
        OTHER: :other
      }.freeze

      # @return [AIXM::Component::VerticalLimits] vertical limits of this layer
      attr_reader :vertical_limits

      # @return [String, nil] primary activity (e.g. "GLIDER")
      attr_reader :activity

      # @return [AIXM::Component::Timetable, nil] activation hours
      attr_reader :timetable

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(class: nil, vertical_limits:)
        self.class = binding.local_variable_get(:class)
        self.vertical_limits = vertical_limits
        self.selective = false
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} class=#{@klass.inspect}>)
      end

      # @!attribute class
      # @return [Symbol] class of layer (see {CLASSES})
      def class
        @klass
      end

      def class=(value)
        @klass = value&.to_sym&.upcase
        fail(ArgumentError, "invalid class") unless @klass.nil? || CLASSES.include?(@klass)
      end

      def vertical_limits=(value)
        fail(ArgumentError, "invalid vertical limits") unless value.is_a? AIXM::Component::VerticalLimits
        @vertical_limits = value
      end

      def activity=(value)
        @activity = value.nil? ? nil : ACTIVITIES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid activity")
      end

      def timetable=(value)
        fail(ArgumentError, "invalid timetable") unless value.nil? || value.is_a?(AIXM::Component::Timetable)
        @timetable = value
      end

      # @!attribute [w] selective
      # @return [Boolean] whether the layer may be activated selectively
      def selective?
        @selective
      end

      def selective=(value)
        fail(ArgumentError, "invalid selective") unless [true, false].include? value
        @selective = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.codeClass(self.class.to_s) if self.class
        builder.codeActivity(ACTIVITIES.key(activity).to_s) if activity
        builder << vertical_limits.to_xml
        builder << timetable.to_xml(as: :Att) if timetable
        builder.codeSelAvbl(selective? ? 'Y' : 'N') if AIXM.ofmx?
        builder.txtRmk(remarks) if remarks
        builder.target!
      end
    end

  end
end
