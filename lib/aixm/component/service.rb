using AIXM::Refinements

module AIXM
  class Component

    # Service provided by a unit.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   service = AIXM.service(
    #     type: TYPES
    #   )
    #   service.timetable = AIXM.timetable or nil
    #   service.remarks = String or nil
    #   service.add_frequency(AIXM.frequency)
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Organisation#ser-service
    class Service < Component
      include AIXM::Association
      include AIXM::Memoize

      TYPES = {
        ACS: :area_control_service,
        ADS: :automatic_dependent_surveillance_service,
        ADVS: :advisory_service,
        AFIS: :aerodrome_flight_information_service,
        AFS: :aeronautical_fixed_service,
        AIS: :aeronautical_information_service,
        ALRS: :alerting_service,
        AMS: :aeronautical_mobile_service,
        AMSS: :aeronautical_mobile_satellite_service,
        APP: :approach_control_service,
        'APP-ARR': :approach_control_service_for_arrival,
        'APP-DEP': :approach_control_service_for_departure,
        ARTCC: :air_route_traffic_control_centre_service,
        ATC: :air_traffic_control_service,
        ATFM: :air_traffic_flow_management_service,
        ATIS: :automated_terminal_information_service,
        'ATIS-ARR': :automated_terminal_information_service_for_arrival,
        'ATIS-DEP': :automated_terminal_information_service_for_departure,
        ATM: :air_traffic_management_service,
        ATS: :air_traffic_service,
        BOF: :briefing_service,
        BS: :commercial_broadcasting_service,
        COM: :communications_service,
        CTAF: :common_traffic_advisory_frequency_service,
        DVDF: :doppler_vdf_service,
        EFAS: :en_route_flight_advisory_service,
        ENTRY: :entry_clearance_service,
        EXIT: :exit_clearance_service,
        FCST: :forecasting_service,
        FIS: :flight_information_service,
        FISA: :automated_flight_information_service,
        FSS: :flight_service_station_service,
        GCA: :ground_controlled_approach_service,
        INFO: :information_provision_service,
        MET: :meteorological_service,
        NOF: :international_notam_service,
        OAC: :oceanic_area_control_service,
        OVERFLT: :overflight_clearance_service,
        PAR: :precision_approach_radar_service,
        RAC: :rules_of_the_air_and_air_traffic_services,
        RADAR: :radar_service,
        RAF: :regional_area_forecasting_service,
        RCC: :rescue_coordination_service,
        SAR: :search_and_rescue_service,
        SIGMET: :sigmet_service,
        SMC: :surface_movement_control_service,
        SMR: :surface_movement_radar_service,
        SRA: :surveillance_radar_approach_service,
        SSR: :secondary_surveillance_radar_service,
        TAR: :terminal_area_radar_service,
        TWEB: :transcribed_weather_broadcast_service,
        TWR: :aerodrome_control_tower_service,
        UAC: :upper_area_control_service,
        UDF: :uhf_direction_finding_service,
        VDF: :vhf_direction_finding_service,
        VOLMET: :volmet_service,
        VOT: :vor_test_facility,
        OTHER: :other   # specify in remarks
      }.freeze

      # Map service types to guessed unit types
      GUESSED_UNIT_TYPES_MAP = {
        :advisory_service => :advisory_centre,
        :aerodrome_control_tower_service => :aerodrome_control_tower,
        :aerodrome_flight_information_service => :aerodrome_control_tower,
        :aeronautical_information_service => :aeronautical_information_services_office,
        :air_route_traffic_control_centre_service => :air_route_traffic_control_centre,
        :air_traffic_control_service => :air_traffic_control_centre,
        :air_traffic_flow_management_service => :air_traffic_flow_management_unit,
        :air_traffic_management_service => :air_traffic_management_unit,
        :air_traffic_service => :air_traffic_services_unit,
        :approach_control_service => :approach_control_office,
        :approach_control_service_for_arrival => :arrivals_approach_control_office,
        :approach_control_service_for_departure => :depatures_approach_control_office,
        :area_control_service => :area_control_centre,
        :automated_terminal_information_service => :aerodrome_control_tower,
        :automated_terminal_information_service_for_arrival => :aerodrome_control_tower,
        :automated_terminal_information_service_for_departure => :aerodrome_control_tower,
        :automatic_dependent_surveillance_service => :automatic_dependent_surveillance_unit,
        :briefing_service => :briefing_office,
        :commercial_broadcasting_service => :commercial_broadcasting_station,
        :communications_service => :communications_office,
        :flight_information_service => :flight_information_centre,
        :flight_service_station_service => :flight_service_station,
        :forecasting_service => :forecasting_office,
        :ground_controlled_approach_service => :ground_controlled_approach_systems_office,
        :international_notam_service => :international_notam_office,
        :meteorological_service => :meteorological_office,
        :oceanic_area_control_service => :oceanic_control_centre,
        :precision_approach_radar_service => :precision_approach_radar_centre,
        :radar_service => :radar_office,
        :regional_area_forecasting_service => :regional_area_forecast_centre,
        :rescue_coordination_service => :rescue_coordination_centre,
        :search_and_rescue_service => :search_and_rescue_centre,
        :secondary_surveillance_radar_service => :secondary_surveillance_radar_centre,
        :sigmet_service => :meteorological_office,
        :surface_movement_control_service => :surface_movement_control_office,
        :surface_movement_radar_service => :surface_movement_radar_office,
        :surveillance_radar_approach_service => :surveillance_radar_approach_centre,
        :terminal_area_radar_service => :terminal_area_surveillance_radar_centre,
        :transcribed_weather_broadcast_service => :meteorological_office,
        :uhf_direction_finding_service => :uhf_direction_finding_station,
        :upper_area_control_service => :upper_area_control_centre,
        :vhf_direction_finding_service => :vdf_direction_finding_station,
        :volmet_service => :meteorological_office,
        :other => :other
      }.freeze

      # @!method frequencies
      #   @return [Array<AIXM::Component::Frequency>] frequencies used by this service
      #
      # @!method add_frequency(frequency)
      #   @param frequency [AIXM::Component::Frequency]
      has_many :frequencies

      # @!method unit
      #   @return [AIXM::Feature::Unit] unit providing this service
      belongs_to :unit

      # @!method layer
      #   @return [AIXM::Component::Layer] airspace layer this service is provided within
      belongs_to :layer

      # @return [Symbol] type of service (see {TYPES})
      attr_reader :type

      # @return [AIXM::Component::Timetable, nil] operating hours
      attr_reader :timetable

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(type:)
        self.type = type
        @sequence = 1
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

      # Guess the unit type for this service
      #
      # @return [Symbol, nil] guessed unit type or +nil+ if unmappable
      def guessed_unit_type
        GUESSED_UNIT_TYPES_MAP[type]
      end

      # @return [String] UID markup
      def to_uid
        resequence!
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.SerUid do |ser_uid|
          ser_uid << unit.to_uid.indent(2)
          ser_uid.codeType(TYPES.key(type).to_s)
          ser_uid.noSeq(@sequence)
        end
      end
      memoize :to_uid

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! ["Service: #{TYPES.key(type)}", unit&.send(:name_with_type)].compact.join(' by ')
        builder.Ser do |ser|
          ser << to_uid.indent(2)
          ser << timetable.to_xml(as: :Stt).indent(2) if timetable
          ser.txtRmk(remarks) if remarks
        end
        frequencies.each do |frequency|
          builder << frequency.to_xml
        end
        builder.target!
      end

      private

      def resequence!
        unit.services.sort { |a, b| a.type <=> b.type }.each.with_object({}) do |service, sequences|
          sequences[service.type] = (sequences[service.type] || 0) + 1
          service.instance_variable_set(:@sequence, sequences[service.type])
        end
      end

    end

  end
end
