using AIXM::Refinements

module AIXM
  module Feature

    ##
    # Organisation feature
    #
    # Arguments:
    # * +name+ - name of the organisation
    # * +type+ - type of organisation
    class Organisation < Base
      TYPES = {
        S: :state,
        GS: :group_of_states,
        O: :national_organisation,
        IO: :international_organisation,
        AOA: :aircraft_operating_agency,
        ATS: :air_traffic_services_provider,
        HA: :handling_authority,
        A: :national_authority,
        OTHER: :other
      }

      attr_reader :name, :type
      attr_reader :id, :remarks

      public_class_method :new

      def initialize(source: nil, region: nil, name:, type:)
        super(source: source, region: region)
        self.name, self.type = name, type
      end

      ##
      # Name of the organisation (e.g. "FRANCE")
      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      ##
      # Type of organisation
      #
      # Allowed values:
      # * +:state+ (+:S+)
      # * +:group_of_states+ (+:GS+)
      # * +:national_organisation+ (+:O+)
      # * +:international_organisation+ (+:IO+)
      # * +:aircraft_operating_agency+ (+:AOA+)
      # * +:air_traffic_services_provider+ (+:ATS+)
      # * +:handling_authority+ (+:HA+)
      # * +:national_authority+ (+:A+)
      # * +:other+ (+:OTHER+) - specify in +remarks+
      def type=(value)
        @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      ##
      # Code of the organisation (e.g. "LF" for name "FRANCE" and type "S")
      def id=(value)
        fail(ArgumentError, "invalid id") unless value.nil? || value.is_a?(String)
        @id = value&.upcase
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
        builder.OrgUid({ region: (region if AIXM.ofmx?) }.compact) do |org_uid|
          org_uid.txtName(name)
        end
      end

      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Org({ source: (source if AIXM.ofmx?) }.compact) do |org|
          org << to_uid.indent(2)
          org.codeId(id) if id
          org.codeType(TYPES.key(type).to_s)
          org.txtRmk(remarks) if remarks
        end
      end
    end

  end
end
