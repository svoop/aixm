using AIXM::Refinements

module AIXM
  class Feature

    # Units providing all kind of services such as air traffic management,
    # search and rescue, meteorological services and so forth.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   unit = AIXM.unit(
    #     source: String or nil
    #     region: String or nil (falls back to +AIXM.config.region+)
    #     organisation: AIXM.organisation
    #     name: String
    #     type: TYPES
    #     class: :icao or :other
    #   )
    #   unit.airport = AIXM.airport
    #   unit.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Organisation#uni-unit
    class Unit < Feature
      public_class_method :new

      TYPES = {
        ACC: :area_control_centre,
        APP: :approach_control_office,
        ARO: :ats_reporting_office,
        ATSU: :air_traffic_services_unit,
        COM: :communications_office,
        FIC: :flight_information_centre,
        FSS: :flight_service_station,
        MET: :meteorological_office,
        NOF: :international_notam_office,
        RAD: :radar_office,
        TWR: :aerodrome_control_tower,
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

      # @return [AIXM::Feature::Airport] airport
      attr_reader :airport

      # @return [String] free text remarks
      attr_reader :remarks

      def initialize(source: nil, region: nil, organisation:, name:, type:, class:)
        super(source: source, region: region)
        self.organisation, self.name, self.type = organisation, name, type
        self.class = binding.local_variable_get(:class)
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} name=#{name.inspect} type=#{type.inspect}>)
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
        @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      # @!attribute class
      # @return [Symbol] class of unit (see {CLASSES})
      def class
        @klass
      end

      def class=(value)
        @klass = CLASSES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid class")
      end

      def airport=(value)
        fail(ArgumentError, "invalid airport") unless value.is_a? AIXM::Feature::Airport
        @airport = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.UniUid({ region: (region if AIXM.ofmx?) }.compact) do |uni_uid|
          uni_uid.txtName(name)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Uni({ source: (source if AIXM.ofmx?) }.compact) do |uni|
          uni << to_uid.indent(2)
          uni << organisation.to_uid.indent(2)
          uni << airport.to_uid.indent(2) if airport
          uni.codeType(TYPES.key(type).to_s)
          uni.codeClass(CLASSES.key(self.class).to_s)
          uni.txtRmk(remarks) if remarks
        end
      end
    end

  end
end
