using AIXM::Refinements

module AIXM
  module Feature
    module NavigationalAid

      # @abstract
      class Base < AIXM::Feature::Base
        private_class_method :new

        # @return [AIXM::Feature::Organisation] superior organisation
        attr_reader :organisation

        # @return [String] published identifier
        attr_reader :id

        # @return [String] name of the navigational aid
        attr_reader :name

        # @return [AIXM::XY] geographic position
        attr_reader :xy

        # @return [AIXM::Z] elevation in +:qnh+
        attr_reader :z

        # @return [AIXM::Component::Schedule] operating hours
        attr_reader :schedule

        # @return [String] free text remarks
        attr_reader :remarks

        def initialize(source: nil, region: nil, organisation:, id:, name: nil, xy:, z: nil)
          super(source: source, region: region)
          self.organisation, self.id, self.name, self.xy, self.z = organisation, id, name, xy, z
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} id=#{id.inspect}>)
        end

        def organisation=(value)
          fail(ArgumentError, "invalid organisation") unless value == false || value.is_a?(AIXM::Feature::Organisation)
          @organisation = value
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

        def schedule=(value)
          fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
          @schedule = value
        end

        def remarks=(value)
          fail(ArgumentError, "invalid remarks") unless value.nil? || value.is_a?(String)
          @remarks = value
        end

        # @return [String] fully descriptive combination of +class+ and +type+ key
        def kind
          [self.class.name.split('::').last, type_key].compact.join(':')
        end

        private

        def type_key
          nil
        end

        def to_builder
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.comment! "NavigationalAid: [#{kind}] #{name}"
          builder
        end
      end

    end
  end
end
