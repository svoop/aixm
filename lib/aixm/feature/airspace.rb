module AIXM
  module Feature
    class Airspace

      using AIXM::Refinements

      attr_reader :name, :short_name, :type
      attr_reader :vertical_limits
      attr_accessor :geometry, :remarks

      ##
      # Airspace feature
      #
      # Options:
      # * +name+ - full name of the airspace (will be converted to uppercase,
      #            e.g. +LF P 81+)
      # * +short_name+ - short name of the airspace (will be converted to
      #                  uppercase, e.g. +LF P 81 CHERBOURG+)
      # * +type+ - airspace type (e.g. +TMA+ or +P+)
      def initialize(name:, short_name: nil, type:)
        @geometry = AIXM::Geometry.new
        @name, @short_name, @type = name.upcase, short_name&.upcase, type
      end

      ##
      # Assign a +Vertical::Limits+ object
      def vertical_limits=(value)
        fail(ArgumentError, "invalid vertical limit") unless value.is_a?(AIXM::Vertical::Limits)
        @vertical_limits = value
      end

      ##
      # Check whether the airspace is valid
      def valid?
        name && type && vertical_limits && geometry.valid?
      end

      ##
      # Digest to identify the payload
      def to_digest
        [name, type, vertical_limits.to_digest, geometry.to_digest, remarks].to_digest
      end

      ##
      # Render AIXM
      #
      # Extensions:
      # * +:OFM+ - Open Flightmaps
      def to_xml(*extensions)
        mid = to_digest
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Ase(extensions.include?(:OFM) ? { xt_classLayersAvail: false } : {}) do |ase|
          ase.AseUid(extensions.include?(:OFM) ? { mid: mid, newEntity: true } : { mid: mid }) do |aseuid|
            aseuid.codeType(type)
            aseuid.codeId(mid)   # TODO: verify
          end
          ase.txtLocalType(short_name) if short_name && short_name != name
          ase.txtName(name)
          ase << vertical_limits.to_xml(extensions).indent(2)
          ase.txtRmk(remarks) if remarks
          ase.xt_selAvail(false) if extensions.include?(:OFM)
        end
        builder.Abd do |abd|
          abd.AbdUid do |abduid|
            abduid.AseUid(extensions.include?(:OFM) ? { mid: mid, newEntity: true } : { mid: mid }) do |aseuid|
              aseuid.codeType(type)
              aseuid.codeId(mid)   # TODO: verify
            end
          end
          abd << geometry.to_xml(extensions).indent(2)
        end
      end
    end
  end
end
