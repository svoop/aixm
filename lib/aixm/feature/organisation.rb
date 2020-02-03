using AIXM::Refinements

module AIXM
  class Feature

    # Organisations and authorities such as ATS organisations, aircraft
    # operating agencies, states and so forth.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   organisation = AIXM.organisation(
    #     source: String or nil
    #     region: String or nil
    #     name: String
    #     type: TYPES
    #   )
    #   organisation.id = String or nil
    #   organisation.remarks = String or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Organisation#org-organisation
    class Organisation < Feature
      include AIXM::Association

      public_class_method :new

      TYPES = {
        S: :state,
        GS: :group_of_states,
        O: :national_organisation,
        IO: :international_organisation,
        AOA: :aircraft_operating_agency,
        ATS: :air_traffic_services_provider,
        HA: :handling_authority,
        A: :national_authority,
        OTHER: :other                          # specify in remarks
      }.freeze

      # @!method members
      #   @return [Array<AIXM::Feature::Airport,
      #     AIXM::Feature::Unit,
      #     AIXM::Feature::NavigationalAid>] aiports, units or navigational aids
      # @!method add_member
      #   @param [AIXM::Feature::Airport,
      #     AIXM::Feature::Unit,
      #     AIXM::Feature::NavigationalAid]
      #   @return [self]
      has_many :members, accept: [:airport, :unit, 'AIXM::Feature::NavigationalAid']

      # @return [String] name of organisation (e.g. "FRANCE")
      attr_reader :name

      # @return [Symbol] type of organisation (see {TYPES})
      attr_reader :type

      # @return [String, nil] code of the organisation (e.g. "LF")
      attr_reader :id

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(source: nil, region: nil, name:, type:)
        super(source: source, region: region)
        self.name, self.type = name, type
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} name=#{name.inspect} type=#{type.inspect}>)
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def type=(value)
        @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def id=(value)
        fail(ArgumentError, "invalid id") unless value.nil? || value.is_a?(String)
        @id = value&.upcase
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.OrgUid({ region: (region if AIXM.ofmx?) }.compact) do |org_uid|
          org_uid.txtName(name)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Organisation: #{name}"
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
