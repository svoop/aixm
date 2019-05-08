using AIXM::Refinements

module AIXM
  class Feature

    # Three-dimensional volume most notably defining flight zones.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   airspace = AIXM.airspace(
    #     source: String or nil
    #     id: String or nil   # nil is converted to an 8 character digest
    #     type: String or Symbol
    #     local_type: String or nil
    #     name: String or nil
    #   )
    #   airspace.geometry << AIXM.point or AIXM.arc or AIXM.border or AIXM.circle
    #   airspace.layers << AIXM.layer
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
    # @see https://github.com/openflightmaps/ofmx/wiki/Airspace#ase-airspace
    class Airspace < Feature
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

      # @note When assigning +nil+, a 4 byte hex derived from {#type}, {#name}
      #   and {#local_type} is written instead.
      # @return [String] published identifier (e.g. "LFP81")
      attr_reader :id

      # @return [Symbol] type of airspace (see {TYPES})
      attr_reader :type

      # Some regions define additional types. They are usually specified with
      #
      # @return [String, nil] local type (e.g. "RMZ" or "TMZ")
      attr_reader :local_type

      # @return [String, nil] full name (e.g. "LF P 81 CHERBOURG")
      attr_reader :name

      # @return [AIXM::Component::Geometry] horizontal geometrical shape
      attr_accessor :geometry

      # @return [Array<AIXM::Compoment::Layer>] vertical layers
      attr_accessor :layers

      def initialize(source: nil, id: nil, type:, local_type: nil, name: nil)
        super(source: source)
        self.type, self.local_type, self.name = type, local_type, name
        self.id = id
        @geometry = AIXM.geometry
        @layers = []
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

      # @return [String] UID markup
      def to_uid(as: :AseUid)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag.codeType(TYPES.key(type).to_s)
          tag.codeId(id)
        end
      end

      # @raise [AIXM::GeometryError] if the geometry is not closed
      # @raise [AIXM::LayerError] if no layers are defined
      # @return [String] AIXM or OFMX markup
      def to_xml
        fail(LayerError.new("no layers defined", self)) unless layers.any?
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Airspace: [#{TYPES.key(type)}] #{name || :UNNAMED}"
        builder.Ase({ source: (source if AIXM.ofmx?) }.compact) do |ase|
          ase << to_uid.indent(2)
          ase.txtLocalType(local_type) if local_type && local_type != name
          ase.txtName(name) if name
          unless layered?
            ase << layers.first.to_xml.indent(2)
          end
        end
        builder.Abd do |abd|
          abd.AbdUid do |abd_uid|
            abd_uid << to_uid.indent(4)
          end
          abd << geometry.to_xml.indent(2)
        end
        if layered?
          layers.each.with_index do |layer, index|
            layer_airspace = AIXM.airspace(type: 'CLASS', name: "#{name} LAYER #{index + 1}")
            builder.Ase do |ase|
              ase << layer_airspace.to_uid.indent(2)
              ase.txtName(layer_airspace.name)
              ase << layers[index].to_xml.indent(2)
            end
            builder.Adg do |adg|
              adg.AdgUid do |adg_uid|
                adg_uid << layer_airspace.to_uid.indent(4)
              end
              adg << to_uid(as: :AseUidSameExtent).indent(2)
            end
          end
        end
        builder.target!
      end

      private

      def layered?
        layers.count > 1
      end

    end
  end
end
