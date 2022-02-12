using AIXM::Refinements

module AIXM
  class Feature

    # @abstract
    class NavigationalAid < Feature
      include AIXM::Association

      private_class_method :new

      # @!method organisation
      #   @return [AIXM::Feature::Organisation] superior organisation
      belongs_to :organisation, as: :member

      # @return [String] published identifier
      attr_reader :id

      # @return [String, nil] name of the navigational aid
      attr_reader :name

      # @return [AIXM::XY] geographic position
      attr_reader :xy

      # @return [AIXM::Z, nil] elevation in +:qnh+
      attr_reader :z

      # @return [AIXM::Component::Timetable, nil] operating hours
      attr_reader :timetable

      # @return [String, nil] free text remarks
      attr_reader :remarks

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

      def timetable=(value)
        fail(ArgumentError, "invalid timetable") unless value.nil? || value.is_a?(AIXM::Component::Timetable)
        @timetable = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] fully descriptive combination of {#class} and {#type} key
      def kind
        [self.class.name.split('::').last, type_key].compact.join(':'.freeze)
      end

      private

      def type_key
        nil
      end

      def to_builder
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "NavigationalAid: [#{kind}] #{[id, name].compact.join(' / ')}"
        builder
      end
    end

  end
end
