using AIXM::Refinements

module AIXM
  module Feature

    ##
    # Unit feature
    #
    # Arguments:
    # * +organisation+ - responsible organisation
    # * +name+ - name of the unit
    # * +type+ - type of unit
    # * +class+ - class of unit
    class Unit < Base
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
        OTHER: :other
      }

      CLASSES = {
        ICAO: :icao,
        OTHER: :other
      }

      attr_reader :organisation, :name, :type
      attr_reader :airport, :remarks

      public_class_method :new

      def initialize(source: nil, region: nil, organisation:, name:, type:, class:)
        super(source: source, region: region)
        self.organisation, self.name, self.type = organisation, name, type
        self.class = binding.local_variable_get(:class)
      end

      ##
      # Responsible organisation
      def organisation=(value)
        fail(ArgumentError, "invalid organisation") unless value.is_a? AIXM::Feature::Organisation
        @organisation = value
      end

      ##
      # Name of the unit (e.g. "AVIGNON APP")
      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      ##
      # Type of unit
      #
      # Allowed values:
      # * +:area_control_centre+ (+:ACC+)
      # * +:approach_control_office+ (+:APP+)
      # * +:ats_reporting_office+ (+:ARO+)
      # * +:air_traffic_services_unit+ (+:ATSU+)
      # * +:communications_office+ (+:COM+)
      # * +:flight_information_centre+ (+:FIC+)
      # * +:flight_service_station+ (+:FSS+)
      # * +:meteorological_office+ (+:MET+)
      # * +:international_notam_office+ (+:NOF+)
      # * +:radar_office+ (+:RAD+)
      # * +:aerodrome_control_tower+ (+:TWR+)
      # * +:other+ (+:OTHER+) - specify in +remarks+
      def type=(value)
        @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      ##
      # Class of unit
      #
      # Allowed values:
      # * +:icao+ (+:ICAO+)
      # * +:other+ (+:OTHER+) - specify in +remarks+
      def class=(value)
        @klass = CLASSES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid class")
      end

      ##
      # Read the unit class
      #
      # This and other workarounds in the initializer are necessary due to
      # "class" being a reserved keyword in Ruby.
      def class
        @klass
      end

      ##
      # Airport the unit is located at
      def airport=(value)
        fail(ArgumentError, "invalid airport") unless value.is_a? AIXM::Feature::Airport
        @airport = value
      end

      ##
      # Free text remarks
      def remarks=(value)
        @remarks = value&.to_s
      end

      def inspect
        %Q(#<#{self.class} name=#{name.inspect} type=#{type.inspect}>)
      end

      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.UniUid({ region: (region if AIXM.ofmx?) }.compact) do |uni_uid|
          uni_uid.txtName(name)
        end
      end

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
