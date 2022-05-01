using AIXM::Refinements

module AIXM
  class Feature

    # Three-dimensional volume most notably defining flight zones.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   airspace = AIXM.airspace(
    #     source: String or nil
    #     region: String or nil
    #     id: String or nil   # nil is converted to an 8 character digest
    #     type: String or Symbol
    #     local_type: String or nil
    #     name: String or nil
    #   )
    #   airspace.comment = Object or nil
    #   airspace.add_layer(AIXM.layer)
    #   airspace.geometry.add_segment(AIXM.point or AIXM.arc or AIXM.border or AIXM.circle)
    #
    # The +id+ is mandatory, however, you may omit it when initializing a new
    # airspace or assign +nil+ to an existing airspace which will generate a 8
    # character digest from +type+, +local_type+ and +name+.
    #
    # Some regions define additional airspace types. In LF (France) for
    # intance, the types RMZ (radio mandatory zone) and TMZ (transponder
    # mandatory zone) exist. Such airspaces are usually specified together
    # with a generic type such as +:regulated_airspace+:
    #
    #   airspace= AIXM.airspace(type: :regulated_airspace, local_type: "RMZ")
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airspace#ase-airspace
    class Airspace < Feature
      include AIXM::Concerns::Association

      public_class_method :new

      TYPES = {
        NAS: :national_airspace_system,
        FIR: :flight_information_region,
        'FIR-P': :part_of_flight_information_region,
        UIR: :upper_flight_information_region,
        'UIR-P': :part_of_upper_flight_information_region,
        CTA: :control_area,
        'CTA-P': :part_of_control_area,
        OCA: :oceanic_control_area,
        'OCA-P': :part_of_oceanic_control_area,
        UTA: :upper_control_area,
        'UTA-P': :part_of_upper_control_area,
        TMA: :terminal_control_area,
        'TMA-P': :part_of_terminal_control_area,
        CTR: :control_zone,
        'CTR-P': :part_of_control_zone,
        CLASS: :airspace_with_class,
        OTA: :oceanic_transition_area,
        SECTOR: :control_sector,
        'SECTOR-C': :temporarily_consolidated_sector,
        TSA: :temporary_segregated_area,
        TRA: :temporary_reserved_area,
        CBA: :cross_border_area,
        RCA: :reduced_coordination_airspace_procedure,
        RAS: :regulated_airspace,
        AWY: :airway,
        P: :prohibited_area,
        R: :restricted_area,
        'R-AMC': :amc_manageable_restricted_area,
        D: :danger_area,
        'D-AMC': :amc_manageable_danger_area,
        'D-OTHER': :dangerous_activities_area,
        ADIZ: :air_defense_identification_zone,
        A: :alert_area,
        W: :warning_area,
        PROTECT: :protected_from_specific_air_traffic,
        AMA: :minimum_altitude_area,
        ASR: :altimeter_setting_region,
        'NO-FIR': :airspace_outside_any_flight_information_region,
        POLITICAL: :political_area,
        PART: :part_of_airspace
      }.freeze

      # @!method geometry
      #   @return [AIXM::Component::Geometry] horizontal geometry shape
      #
      # @!method geometry=(geometry)
      #   @param geometry [AIXM::Component::Geometry]
      has_one :geometry

      # @!method layers
      #   @return [Array<AIXM::Compoment::Layer>] vertical layers
      #
      # @!method add_layer(layer)
      #   @param layer [AIXM::Compoment::Layer]
      has_many :layers

      # Published identifier (e.g. "LFP81").
      #
      # @note When assigning +nil+, a 4 byte hex derived from {#type}, {#name}
      #   and {#local_type} is written instead.
      #
      # @overload id
      #   @return [String]
      # @overload id=(value)
      #   @param value [String]
      attr_reader :id

      # Type of airspace (see {TYPES})
      #
      # @overload type
      #   @return [Symbol] any of {TYPES}
      # @overload type=(value)
      #   @param value [Symbol] any of {TYPES}
      attr_reader :type

      # Local type.
      #
      # Some regions define additional local types such as "RMZ" or "TMZ". They
      # are often further specifying type +:regulated_airspace+.
      #
      # @overload local_type
      #   @return [String, nil]
      # @overload local_type=(value)
      #   @param value [String, nil]
      attr_reader :local_type

      # Full name (e.g. "LF P 81 CHERBOURG")
      #
      # @overload name
      #   @return [String, nil]
      # @overload name=(value)
      #   @param value [String, nil]
      attr_reader :name

      # See the {cheat sheet}[AIXM::Feature::Airspace] for examples on how to
      # create instances of this class.
      def initialize(source: nil, region: nil, id: nil, type:, local_type: nil, name: nil)
        super(source: source, region: region)
        self.type, self.local_type, self.name = type, local_type, name
        self.id = id
        self.geometry = AIXM.geometry
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} type=#{type.inspect} name=#{name.inspect}>)
      end

      # The +id+ is mandatory, however, you may assign +nil+ which will generate
      # an 8 character digest from +type+, +local_type+ and +name+.
      def id=(value)
        fail(ArgumentError, "invalid id") unless value.nil? || value.is_a?(String)
        @id = value&.uptrans || [type, local_type, name].to_digest.upcase
      end

      def type=(value)
        @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def local_type=(value)
        fail(ArgumentError, "invalid short name") unless value.nil? || value.is_a?(String)
        @local_type = value&.uptrans
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.nil? || value.is_a?(String)
        @name = value&.uptrans
      end

      # @!visibility private
      def add_uid_to(builder, as: :AseUid)
        builder.send(as, ({ region: (region if AIXM.ofmx?) }.compact)) do |tag|
          tag.codeType(TYPES.key(type))
          tag.codeId(id)
          tag.txtLocalType(local_type) if AIXM.ofmx? && local_type && local_type != name
        end
      end

      # @!visibility private
      def add_wrapped_uid_to(builder, as: :AseUid, with:)
        builder.send(with) do |tag|
          add_uid_to(tag, as: as)
        end
      end

      # @!visibility private
      def add_to(builder)
        fail(LayerError.new("no layers defined", self)) unless layers.any?
        builder.comment "Airspace: [#{TYPES.key(type)}] #{name || :UNNAMED}".dress
        builder.text "\n"
        builder.Ase({ source: (source if AIXM.ofmx?) }.compact) do |ase|
          ase.comment(indented_comment) if comment
          add_uid_to(ase)
          ase.txtLocalType(local_type) if AIXM.aixm? && local_type && local_type != name
          ase.txtName(name) if name
          layers.first.add_to(ase) unless layered?
        end
        builder.Abd do |abd|
          add_wrapped_uid_to(abd, with: :AbdUid)
          geometry.add_to(abd)
        end
        if layered?
          layers.each.with_index do |layer, index|
            layer_airspace = AIXM.airspace(region: region, type: 'CLASS', name: "#{name} LAYER #{index + 1}")
            builder.Ase do |ase|
              layer_airspace.add_uid_to(ase)
              ase.txtName(layer_airspace.name)
              layers[index].add_to(ase)
            end
            builder.Adg do |adg|
              layer_airspace.add_wrapped_uid_to(adg, with: :AdgUid)
              add_uid_to(adg, as: :AseUidSameExtent)
            end
            layer.services.each do |service|
              builder.Sae do |sae|
                sae.SaeUid do |sae_uid|
                  service.add_uid_to(sae_uid)
                  layer_airspace.add_uid_to(sae_uid)
                end
              end
            end
          end
        else
          layers.first.services.each do |service|
            builder.Sae do |sae|
              sae.SaeUid do |sae_uid|
                service.add_uid_to(sae_uid)
                add_uid_to(sae_uid)
              end
            end
          end
        end
      end

      private

      def layered?
        layers.count > 1
      end
    end
  end
end
