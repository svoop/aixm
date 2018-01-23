module AIXM
  module Feature
    class Airspace

      using AIXM::Refinements

      attr_reader :name, :short_name, :type
      attr_reader :schedule
      attr_accessor :geometry, :class_layers, :remarks

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
        @name, @short_name, @type = name.uptrans, short_name&.uptrans, type
        @schedule = nil
        @geometry = AIXM.geometry
        @class_layers = []
      end

      ##
      # Assign a +Schedule+ object or +nil+
      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      ##
      # Check whether the airspace is complete
      def complete?
        !!name && !!type && class_layers.any? && geometry.complete?
      end

      ##
      # Digest to identify the payload
      def to_digest
        [name, short_name, type, schedule&.to_digest, class_layers.map(&:to_digest), geometry.to_digest, remarks].to_digest
      end

      ##
      # Render AIXM
      def to_xml(*extensions)
        mid = to_digest
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Airspace: [#{type}] #{name}"
        builder.Ase({ xt_classLayersAvail: ((class_layers.count > 1) if extensions >> :OFM) }.compact) do |ase|
          ase.AseUid({ mid: mid, newEntity: (true if extensions >> :OFM) }.compact) do |aseuid|
            aseuid.codeType(type.to_s)
            aseuid.codeId(mid)
          end
          ase.txtLocalType(short_name.to_s) if short_name && short_name != name
          ase.txtName(name.to_s)
          ase << class_layers.first.to_xml(*extensions).indent(2)
          if schedule
            ase.Att do |att|
              att << schedule.to_xml(*extensions).indent(4)
            end
          end
          ase.txtRmk(remarks.to_s) if remarks
          ase.xt_selAvail(false) if extensions >> :OFM
        end
        builder.Abd do |abd|
          abd.AbdUid do |abduid|
            abduid.AseUid({ mid: mid, newEntity: (true if extensions >> :OFM) }.compact) do |aseuid|
              aseuid.codeType(type.to_s)
              aseuid.codeId(mid)
            end
          end
          abd << geometry.to_xml(*extensions).indent(2)
        end
        if class_layers.count > 1
          builder.Adg do |adg|
            class_layers.each.with_index do |class_layer, index|
              adg.AdgUid do |adguid|
                adguid.AseUid(mid: "#{mid}.#{index + 1}") do |aseuid|
                  aseuid.codeType("CLASS")
                end
              end
            end
            adg.AseUidSameExtent(mid: mid)
          end
          class_layers.each.with_index do |class_layer, index|
            builder.Ase do |ase|
              ase.AseUid(mid: "#{mid}.#{index + 1}") do |aseuid|
                aseuid.codeType("CLASS")
              end
              ase.txtName(name.to_s)
              ase << class_layers[index].to_xml(*extensions).indent(2)
            end
          end
        end
        builder.target!   # see https://github.com/jimweirich/builder/issues/42
      end
    end
  end
end
