module AIXM
  module Feature
    class Airspace

      using AIXM::Refinement::Digest

      attr_reader :name, :type
      attr_reader :vertical_limits
      attr_accessor :geometry, :remarks

      def initialize(name:, type:)
        @geometry = AIXM::Geometry.new
        @name, @type = name, type
      end

      def vertical_limits=(value)
        fail(ArgumentError, "invalid vertical limit") unless value.is_a?(AIXM::Vertical::Limits)
        @vertical_limits = value
      end

      def valid?
        name && type && vertical_limits && geometry.valid?
      end

      ##
      # Digest to identify the payload
      def to_digest
        [name, type, vertical_limits.to_digest, geometry.to_digest, remarks].to_digest
      end

      def to_xml(mid: nil)
        mid = to_digest
        builder = Builder::XmlMarkup.new
        builder.Ase(AIXM.ofm? ? { xt_classLayersAvail: false } : {}) do |ase|
          ase.AseUid(mid: mid, newEntity: true) do |aseuid|
            aseuid.codeType(type)
          end
          ase.txtName(name)
          ase << vertical_limits.to_xml
          ase.xt_txtRmk(remarks) if AIXM.ofm? && remarks
          ase.xt_selAvail(false) if AIXM.ofm?
        end
        builder.Abd do |abd|
          abd.AbdUid do |abduid|
            abduid.AseUid(mid: mid, newEntity: true) do |aseuid|
              aseuid.codeType(type)
            end
          end
          abd << geometry.to_xml
        end
      end

      def hash

      end

    end
  end
end
