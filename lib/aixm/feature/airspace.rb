using AIXM::Refinements

module AIXM
  module Feature

    ##
    # Airspace feature
    #
    # Options:
    # * +id+ - published identifier (e.g. +LFP81+) or +nil+ to assign a 8 byte
    #          hex digest derived from +type+, +name+ and +short_name+
    # * +name+ - full name of the airspace (e.g. +LF P 81+)
    # * +short_name+ - short name of the airspace (e.g. +LF P 81 CHERBOURG+)
    # * +type+ - airspace type (e.g. +TMA+ or +P+)
    class Airspace
      attr_reader :id, :type, :name, :short_name, :schedule, :remarks
      attr_accessor :geometry, :class_layers

      def initialize(id: nil, type:, name:, short_name: nil)
        self.type, self.name, self.short_name = type, name, short_name
        self.id = id
        @schedule = nil
        @geometry = AIXM.geometry
        @class_layers = []
      end

      def id=(value)
        fail(ArgumentError, "invalid id") unless value.nil? || value.is_a?(String)
        @id = value&.uptrans || [type, name, short_name].to_digest.upcase
      end

      def type=(value)
        fail(ArgumentError, "invalid type") unless value.is_a?(String)
        @type = value.upcase
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def short_name=(value)
        fail(ArgumentError, "invalid short name") unless value.nil? || value.is_a?(String)
        @short_name = value&.uptrans
      end

      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      def remarks=(value)
        fail(ArgumentError, "invalid remarks") unless value.is_a?(String)
        @remarks = value
      end

      def to_uid(as: :AseUid)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |uid|
          uid.codeType(type)
          uid.codeId(id)
        end
      end

      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Airspace: [#{type}] #{name}"
        builder.Ase({ classLayers: (class_layers.count if AIXM.ofmx? && class_layers.count > 1) }.compact) do |ase|
          ase << to_uid.indent(2)
          ase.txtLocalType(short_name.to_s) if short_name && short_name != name
          ase.txtName(name.to_s)
          unless class_layers.count > 1
            ase << class_layers.first.to_xml.indent(2)
            if schedule
              ase.Att do |att|
                att << schedule.to_xml.indent(4)
              end
            end
            ase.codeSelAvbl(false) if AIXM.ofmx?
            ase.txtRmk(remarks.to_s) if remarks
          end
        end
        builder.Abd do |abd|
          abd.AbdUid do |abduid|
            abduid << to_uid.indent(4)
          end
          abd << geometry.to_xml.indent(2)
        end
        if class_layers.count > 1
          class_layers.each.with_index do |class_layer, index|
            class_airspace = AIXM.airspace(type: 'CLASS', name: "#{name} CL#{index}")
            builder.Ase do |ase|
              ase << class_airspace.to_uid.indent(2)
              ase.txtName(name.to_s)
              ase << class_layers[index].to_xml.indent(2)
            end
            builder.Adg do |adg|
              adg.AdgUid do |adguid|
                adguid << class_airspace.to_uid.indent(4)
              end
              adg << to_uid(as: :AseUidSameExtent).indent(2)
            end
          end
        end
        builder.target!   # see https://github.com/jimweirich/builder/issues/42
      end
    end
  end
end
