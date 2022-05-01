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
    #   organisation.comment = Object or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Organisation#org-organisation
    class Organisation < Feature
      include AIXM::Concerns::Association
      include AIXM::Concerns::Remarks

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
      #   @return [Array<AIXM::Feature::Airport, AIXM::Feature::Unit,
      #     AIXM::Feature::NavigationalAid>] aiports, units or navigational aids
      #
      # @!method add_member(member)
      #   @param member [AIXM::Feature::Airport, AIXM::Feature::Unit,
      #     AIXM::Feature::NavigationalAid]
      #   @return [self]
      has_many :members, accept: [:airport, :unit, 'AIXM::Feature::NavigationalAid']

      # Name of organisation (e.g. "FRANCE")
      #
      # @overload name
      #   @return [String]
      # @overload name=(value)
      #   @param value [String]
      attr_reader :name

      # Type of organisation
      #
      # @overload type
      #   @return [Symbol] any of {TYPES}
      # @overload type=(value)
      #   @param value [Symbol] any of {TYPES}
      attr_reader :type

      # Code of the organisation (e.g. "LF")
      #
      # @overload id
      #   @return [String, nil]
      # @overload id=(value)
      #   @param value [String, nil]
      attr_reader :id

      # See the {cheat sheet}[AIXM::Feature::Organisation] for examples on how to
      # create instances of this class.
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

      # @!visibility private
      def add_uid_to(builder)
        builder.OrgUid({ region: (region if AIXM.ofmx?) }.compact) do |org_uid|
          org_uid.txtName(name)
        end
      end

      # @!visibility private
      def add_to(builder)
        builder.comment "Organisation: #{name}".dress
        builder.text "\n"
        builder.Org({ source: (source if AIXM.ofmx?) }.compact) do |org|
          org.comment(indented_comment) if comment
          add_uid_to(org)
          org.codeId(id) if id
          org.codeType(TYPES.key(type))
          org.txtRmk(remarks) if remarks
        end
      end
    end

  end
end
