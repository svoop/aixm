using AIXM::Refinements

module AIXM
  module Feature

    ##
    # Airspace feature
    #
    # Accessors:
    # * +geometry+ - instance of +AIXM::Component::Geometry+
    # * +layers+ - array of instances of +AIXM::Component::Layer+
    class Airspace < Base
      attr_reader :id, :type, :name, :short_name
      attr_accessor :geometry, :layers

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
      }

      def initialize(source: nil, region: nil, id: nil, type:, name:, short_name: nil)
        super(source: source, region: region)
        self.type, self.name, self.short_name = type, name, short_name
        self.id = id
        @geometry = AIXM.geometry
        @layers = []
      end

      def inspect
        %Q(#<#{self.class} type=#{type.inspect} name=#{name.inspect}>)
      end

      ##
      # Published identifier (e.g. "LFP81")
      #
      # Passing +nil+ will assign a 8 byte hex digest derived from +type+,
      # +name+ and +short_name+.
      def id=(value)
        fail(ArgumentError, "invalid id") unless value.nil? || value.is_a?(String)
        @id = value&.uptrans || [type, name, short_name].to_digest.upcase
      end

      ##
      # Airspace type (e.g. "TMA" or "P")
      def type=(value)
        @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      ##
      # Full name (e.g. "LF P 81 CHERBOURG")
      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      ##
      # Short name (e.g. "LF P 81")
      def short_name=(value)
        fail(ArgumentError, "invalid short name") unless value.nil? || value.is_a?(String)
        @short_name = value&.uptrans
      end

      def to_uid(as: :AseUid)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as, { region: (region if AIXM.ofmx?) }.compact) do |tag|
          tag.codeType(TYPES.key(type).to_s)
          tag.codeId(id)
        end
      end

      def to_xml
        fail "geometry not closed" unless geometry.closed?
        fail "no layers defined" unless layers.any?
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Airspace: [#{TYPES.key(type)}] #{name}"
        builder.Ase({
          source: (source if AIXM.ofmx?),
          classLayers: (layers.count if AIXM.ofmx? && layered?)
        }.compact) do |ase|
          ase << to_uid.indent(2)
          ase.txtLocalType(short_name) if short_name && short_name != name
          ase.txtName(name)
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
            layer_airspace = AIXM.airspace(region: region, type: 'CLASS', name: "#{name} LAYER #{index + 1}")
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
