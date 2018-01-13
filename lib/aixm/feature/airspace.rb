module AIXM
  module Feature
    class Airspace

      using AIXM::Refinements

      attr_reader :name, :type
      attr_reader :vertical_limits
      attr_accessor :geometry, :remarks

      def initialize(name:, type:)
        @geometry = AIXM::Geometry.new
        @name, @type = name.upcase, type
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

      def to_xml(*extensions)
        mid = to_digest
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Ase(extensions.include?(:ofm) ? { xt_classLayersAvail: false } : {}) do |ase|
          ase.AseUid(extensions.include?(:ofm) ? { mid: mid, newEntity: true } : { mid: mid }) do |aseuid|
            aseuid.codeType(type)
            aseuid.codeId(mid)   # TODO: verify
          end
          ase.txtName(name)
          ase << vertical_limits.to_xml(extensions).indent(2)
          ase.txtRmk(remarks) if remarks
          if extensions.include?(:ofm)
            ase.xt_txtRmk(remarks)
            ase.xt_selAvail(false)
          end
        end
        builder.Abd do |abd|
          abd.AbdUid do |abduid|
            abduid.AseUid(extensions.include?(:ofm) ? { mid: mid, newEntity: true } : { mid: mid }) do |aseuid|
              aseuid.codeType(type)
              aseuid.codeId(mid)   # TODO: verify
            end
          end
          abd << geometry.to_xml(extensions).indent(2)
        end
      end

      def hash

      end

    end
  end
end
