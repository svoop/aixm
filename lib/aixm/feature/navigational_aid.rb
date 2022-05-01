using AIXM::Refinements

module AIXM
  class Feature

    # @abstract
    class NavigationalAid < Feature
      include AIXM::Concerns::Association
      include AIXM::Concerns::Timetable
      include AIXM::Concerns::Remarks

      private_class_method :new

      # @!method organisation
      #   @return [AIXM::Feature::Organisation] superior organisation
      belongs_to :organisation, as: :member

      # Published identifier
      #
      # @overload id
      #   @return [String]
      # @overload id=(value)
      #   @param value [String]
      attr_reader :id

      # Name of the navigational aid.
      #
      # @overload name
      #   @return [String, nil]
      # @overload name=(value)
      #   @param value [String, nil]
      attr_reader :name

      # Geographic position.
      #
      # @overload xy
      #   @return [AIXM::XY]
      # @overload xy=(value)
      #   @param value [AIXM::XY]
      attr_reader :xy

      # Elevation in +:qnh+.
      #
      # @overload z
      #   @return [AIXM::Z, nil]
      # @overload z=(value)
      #   @param value [AIXM::Z, nil]
      attr_reader :z

      def initialize(source: nil, region: nil, organisation:, id:, name: nil, xy:, z: nil)
        super(source: source, region: region)
        self.organisation, self.id, self.name, self.xy, self.z = organisation, id, name, xy, z
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} id=#{id.inspect} name=#{name.inspect}>)
      end

      def id=(value)
        fail(ArgumentError, "invalid id") unless value.is_a? String
        @id = value.upcase
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.nil? || value.is_a?(String)
        @name = value&.uptrans
      end

      def xy=(value)
        fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
        @xy = value
      end

      def z=(value)
        fail(ArgumentError, "invalid z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
        @z = value
      end

      # Fully descriptive combination of {#class} and {#type} key.
      #
      # @return [String]
      def kind
        [self.class.name.split('::').last, type_key].compact.join(':'.freeze)
      end

      # @!visibility private
      def add_to(builder)
        builder.comment "NavigationalAid: [#{kind}] #{[id, name].compact.join(' / ')}".dress
        builder.text "\n"
      end

      private

      def type_key
        nil
      end
    end

  end
end
