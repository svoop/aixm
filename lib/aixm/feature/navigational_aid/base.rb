using AIXM::Refinements

module AIXM
  module Feature
    module NavigationalAid

      ##
      # Implements common attributes of all navigational aids
      #
      # Arguments:
      # * +id+ - published identifier
      # * +name+ - full name
      # * +xy+ - position
      # * +z+ - elevation in +:qnh+
      class Base < AIXM::Feature::Base
        attr_reader :id, :name, :xy, :z, :schedule, :remarks

        private_class_method :new

        def initialize(source: nil, region: nil, id:, name: nil, xy:, z: nil)
          super(source: source, region: region)
          self.id, self.name, self.xy, self.z = id, name, xy, z
        end

        ##
        # Published identifier
        def id=(value)
          fail(ArgumentError, "invalid id") unless value.is_a? String
          @id = value.upcase
        end

        ##
        # Full name
        def name=(value)
          fail(ArgumentError, "invalid name") unless value.nil? || value.is_a?(String)
          @name = value&.uptrans
        end

        ##
        # Position
        def xy=(value)
          fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
          @xy = value
        end

        ##
        # Elevation in +qnh+
        def z=(value)
          fail(ArgumentError, "invalid z") unless value.nil? || (value.is_a?(AIXM::Z) && value.qnh?)
          @z = value
        end

        ##
        # Schedule as instance of +AIXM::Component::Schedule+
        def schedule=(value)
          fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
          @schedule = value
        end

        ##
        # Free text remarks
        def remarks=(value)
          fail(ArgumentError, "invalid remarks") unless value.nil? || value.is_a?(String)
          @remarks = value
        end

        ##
        # Fallback type key
        def type_key
          nil
        end

        ##
        # Return a fully descriptive combination of +class+ and +type_key+
        def kind
          [self.class.name.split('::').last, type_key].compact.join(':')
        end

        ##
        # Create builder to render AIXM in subclasses
        def to_builder
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.comment! "NavigationalAid: [#{kind}] #{name}"
          builder
        end
      end

    end
  end
end
