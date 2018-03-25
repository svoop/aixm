using AIXM::Refinements

module AIXM
  module Feature

    ##
    # Airspace feature
    #
    # Arguments:
    # * +id+ - published identifier (e.g. "LFP81") or +nil+ to assign a 8 byte
    #          hex digest derived from +type+, +name+ and +short_name+
    # * +type+ - airspace type (e.g. "TMA" or "P")
    # * +name+ - full name of the airspace (e.g. "LF P 81")
    # * +short_name+ - short name of the airspace (e.g. "LF P 81 CHERBOURG")
    #
    # Writers:
    # * +geometry+ - instance of +AIXM::Component::Geometry+
    # * +layers+ - array of instances of +AIXM::Component::Layer+
    class Airspace
      attr_reader :id, :type, :name, :short_name
      attr_accessor :geometry, :layers

      def initialize(id: nil, type:, name:, short_name: nil)
        self.type, self.name, self.short_name = type, name, short_name
        self.id = id
        @geometry = AIXM.geometry
        @layers = []
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

      def to_uid(as: :AseUid)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |uid|
          uid.codeType(type)
          uid.codeId(id)
        end
      end

      def to_xml
        fail "geometry not closed" unless geometry.closed?
        fail "no layers defined" unless layers.any?
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Airspace: [#{type}] #{name}"
        builder.Ase({ classLayers: (layers.count if AIXM.ofmx? && layered?) }.compact) do |ase|
          ase << to_uid.indent(2)
          ase.txtLocalType(short_name) if short_name && short_name != name
          ase.txtName(name)
          unless layered?
            ase << layers.first.to_xml.indent(2)
          end
        end
        builder.Abd do |abd|
          abd.AbdUid do |abduid|
            abduid << to_uid.indent(4)
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
              adg.AdgUid do |adguid|
                adguid << layer_airspace.to_uid.indent(4)
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
