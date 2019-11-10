using AIXM::Refinements

module AIXM
  class Feature

    # Units providing all kind of services such as air traffic management,
    # search and rescue, meteorological services and so forth.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   unit = AIXM.unit(
    #     source: String or nil
    #     organisation: AIXM.organisation
    #     name: String
    #     type: TYPES
    #     class: :icao or :other
    #   )
    #   unit.airport = AIXM.airport or nil
    #   unit.remarks = String or nil
    #   unit.add_service(AIXM.service)
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Organisation#uni-unit
    class Unit < Feature
      public_class_method :new

      TYPES = {
        ACC: :area_control_centre,
        ADSU: :automatic_dependent_surveillance_unit,
        ADVC: :advisory_centre,
        ALPS: :alerting_post,
        AOF: :aeronautical_information_services_office,
        APP: :approach_control_office,
        'APP-ARR': :arrivals_approach_control_office,
        'APP-DEP': :depatures_approach_control_office,
        ARO: :air_traffic_service_reporting_office,
        ARTCC: :air_route_traffic_control_centre,
        ATCC: :air_traffic_control_centre,
        ATFMU: :air_traffic_flow_management_unit,
        ATMU: :air_traffic_management_unit,
        ATSU: :air_traffic_services_unit,
        BOF: :briefing_office,
        BS: :commercial_broadcasting_station,
        COM: :communications_office,
        FCST: :forecasting_office,
        FIC: :flight_information_centre,
        FSS: :flight_service_station,
        GCA: :ground_controlled_approach_systems_office,
        MET: :meteorological_office,
        MIL: :military_station,
        MILOPS: :military_flight_operations_briefing_office,
        MWO: :meteorological_watch_office,
        NOF: :international_notam_office,
        OAC: :oceanic_control_centre,
        PAR: :precision_approach_radar_centre,
        RAD: :radar_office,
        RAFC: :regional_area_forecast_centre,
        RCC: :rescue_coordination_centre,
        RSC: :rescue_sub_centre,
        SAR: :search_and_rescue_centre,
        SMC: :surface_movement_control_office,
        SMR: :surface_movement_radar_office,
        SRA: :surveillance_radar_approach_centre,
        SSR: :secondary_surveillance_radar_centre,
        TAR: :terminal_area_surveillance_radar_centre,
        TRACON: :terminal_radar_approach_control,
        TWR: :aerodrome_control_tower,
        UAC: :upper_area_control_centre,
        UDF: :uhf_direction_finding_station,
        UIC: :upper_information_centre,
        VDF: :vdf_direction_finding_station,
        WAFC: :world_area_forecast_centre,
        OTHER: :other                       # specify in remarks
      }.freeze

      CLASSES = {
        ICAO: :icao,
        OTHER: :other   # specify in remarks
      }.freeze

      # @return [AIXM::Feature::Organisation] superior organisation
      attr_reader :organisation

      # @return [String] name of unit (e.g. "MARSEILLE ACS")
      attr_reader :name

      # @return [Symbol] type of unit (see {TYPES})
      attr_reader :type

      # @return [AIXM::Feature::Airport, nil] airport
      attr_reader :airport

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(source: nil, organisation:, name:, type:, class:)
        super(source: source)
        self.organisation, self.name, self.type = organisation, name, type
        self.class = binding.local_variable_get(:class)
        @services = []
      end

      # @return [String]
      def inspect
        %Q(#<#{original_class} name=#{name.inspect} type=#{type.inspect}>)
      end

      def organisation=(value)
        fail(ArgumentError, "invalid organisation") unless value.is_a? AIXM::Feature::Organisation
        @organisation = value
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def type=(value)
        @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      # @!attribute class
      # @note Use +original_class+ to query the Ruby object class.
      # @return [Symbol] class of unit (see {CLASSES})
      alias_method :original_class, :class
      def class
        @klass
      end

      def class=(value)
        @klass = CLASSES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid class")
      end

      def airport=(value)
        fail(ArgumentError, "invalid airport") unless value.nil? || value.is_a?(AIXM::Feature::Airport)
        @airport = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # Add a service provided by this unit.
      #
      # @param service [AIXM::Feature::Service] service instance
      # @return [self]
      def add_service(service)
        fail(ArgumentError, "invalid service") unless service.is_a? AIXM::Feature::Service
        service.send(:unit=, self)
        @services << service
        self
      end

      # @!attribute [r] services
      # @return [Array<AIXM::Feature::Service>] services provided by this unit
      def services
        @services.sort { |a, b| a.type <=> b.type }
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.UniUid do |uni_uid|
          uni_uid.txtName(name)
          uni_uid.codeType(TYPES.key(type).to_s) if AIXM.ofmx?
        end.insert_payload_hash(region: AIXM.config.mid_region)
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Unit: #{name_with_type}"
        builder.Uni({ source: (source if AIXM.ofmx?) }.compact) do |uni|
          uni << to_uid.indent(2)
          uni << organisation.to_uid.indent(2)
          uni << airport.to_uid.indent(2) if airport
          uni.codeType(TYPES.key(type).to_s) unless AIXM.ofmx?
          uni.codeClass(CLASSES.key(self.class).to_s)
          uni.txtRmk(remarks) if remarks
        end
        services.each.with_object({}) do |service, sequences|
          sequences[service.type] = (sequences[service.type] || 0) + 1
          builder << service.to_xml(sequence: sequences[service.type])
        end
        builder.target!
      end

      private

      def name_with_type
        [name, TYPES.key(type)].join(' ')
      end
    end

  end
end
