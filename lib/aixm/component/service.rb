using AIXM::Refinements

module AIXM
  class Component

    # Service provided by a unit.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   service = AIXM.service(
    #     name: String
    #     type: TYPES
    #   )
    #   service.schedule = AIXM.schedule or nil
    #   service.remarks = String or nil
    #   service.add_frequency(AIXM.frequency)
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Organisation#ser-service
    class Service
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

      # @return [AIXM::Feature::Unit] unit providing this service
      attr_reader :unit

      # @return [String] full name
      attr_reader :name

      # @return [Symbol] type of service (see {TYPES})
      attr_reader :type

      # @return [AIXM::Component::Schedule, nil] operating hours
      attr_reader :schedule

      # @return [String, nil] free text remarks
      attr_reader :remarks

      # @return [Array<AIXM::Component::Frequency>] frequencies used by this service
      attr_reader :frequencies

      def initialize(name:, type:)
        self.name, self.type = name, type
        @frequencies = []
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} type=#{type.inspect}>)
      end

      def unit=(value)
        fail(ArgumentError, "invalid unit") unless value.is_a? AIXM::Feature::Unit
        @unit = value
      end
      private :unit=

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def type=(value)
        @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # Add a frequency used by this service.
      #
      # @param frequency [AIXM::Component::Frequency] frequency instance
      # @return [self]
      def add_frequency(frequency)
        fail(ArgumentError, "invalid frequency") unless frequency.is_a? AIXM::Component::Frequency
        frequency.send(:service=, self)
        @frequencies << frequency
        self
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.SerUid do |ser_uid|
          ser_uid << unit.to_uid.indent(2)
          ser_uid.codeType(TYPES.key(type).to_s)
          ser_uid.noSeq(@sequence)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml(sequence=1)
        @sequence = sequence
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Ser do |ser|
          ser << to_uid.indent(2)
          ser << schedule.to_xml(as: :Stt).indent(2) if schedule
          ser.txtRmk(remarks) if remarks
        end
        frequencies.each do |frequency|
          builder << frequency.to_xml
        end
        builder.target!
      end
    end

  end
end
