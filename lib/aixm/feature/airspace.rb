using AIXM::Refinements

module AIXM
  module Feature

    ##
    # Airspace feature
    #
    # Options:
    # * +name+ - full name of the airspace (will be converted to uppercase,
    #            e.g. +LF P 81+)
    # * +short_name+ - short name of the airspace (will be converted to
    #                  uppercase, e.g. +LF P 81 CHERBOURG+)
    # * +type+ - airspace type (e.g. +TMA+ or +P+)
    class Airspace
      attr_reader :name, :short_name, :type, :schedule, :remarks
      attr_accessor :geometry, :class_layers

      def initialize(name:, short_name: nil, type:)
        self.name, self.short_name, self.type = name, short_name, type
        @schedule = nil
        @geometry = AIXM.geometry
        @class_layers = []
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def short_name=(value)
        fail(ArgumentError, "invalid short name") unless value.nil? || value.is_a?(String)
        @short_name = value&.uptrans
      end

      def type=(value)
        fail(ArgumentError, "invalid type") unless value.is_a?(String)
        @type = value.upcase
      end

      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      def remarks=(value)
        fail(ArgumentError, "invalid remarks") unless value.is_a?(String)
        @remarks = value
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
      # Render UID markup
      def to_uid
        mid = to_digest
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.AseUid({ mid: mid, newEntity: (true if AIXM.ofmx?) }.compact) do |aseuid|
          aseuid.codeType(type)
          aseuid.codeId(mid)
        end
      end

      ##
      # Render XML
      def to_xml
        mid = to_digest
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Airspace: [#{type}] #{name}"
        builder.Ase({ xt_classLayersAvail: ((class_layers.count > 1) if AIXM.ofmx?) }.compact) do |ase|
          ase << to_uid.indent(2)
          ase.txtLocalType(short_name.to_s) if short_name && short_name != name
          ase.txtName(name.to_s)
          ase << class_layers.first.to_xml.indent(2)
          if schedule
            ase.Att do |att|
              att << schedule.to_xml.indent(4)
            end
          end
          ase.txtRmk(remarks.to_s) if remarks
          ase.xt_selAvail(false) if AIXM.ofmx?
        end
        builder.Abd do |abd|
          abd.AbdUid do |abduid|
            abduid.AseUid({ mid: mid, newEntity: (true if AIXM.ofmx?) }.compact) do |aseuid|
              aseuid.codeType(type)
              aseuid.codeId(mid)
            end
          end
          abd << geometry.to_xml.indent(2)
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
              ase << class_layers[index].to_xml.indent(2)
            end
          end
        end
        builder.target!   # see https://github.com/jimweirich/builder/issues/42
      end
    end
  end
end
