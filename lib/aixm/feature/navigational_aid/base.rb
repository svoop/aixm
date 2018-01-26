module AIXM
  module Feature
    module NavigationalAid

      ##
      # Implements common attributes of all navigational aids
      #
      # Please note that the optional elevation +z+ must be in +:qnh+.
      class Base < AIXM::Feature::Base
        using AIXM::Refinements

        attr_reader :id, :name, :xy, :z, :schedule, :remarks

        private_class_method :new

        def initialize(id:, name:, xy:, z: nil)
          self.id, self.name, self.xy, self.z = id, name, xy, z
        end

        def id=(value)
          fail(ArgumentError, "invalid id") unless value.is_a? String
          @id = value.upcase
        end

        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? String
          @name = value.upcase
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
          fail(ArgumentError, "invalid remarks") unless value.is_a? String
          @remarks = value
        end

        ##
        # Return a fully descriptive combination of +class+ and +type_key+
        def kind
          [self.class.name.split('::').last, type_key].compact.join(':')
        end

        ##
        # Digest to identify the payload
        def to_digest
          [kind, id, name, xy.to_digest, z&.to_digest, remarks].to_digest
        end

        ##
        # Create builder to render AIXM in subclasses
        def to_builder(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.comment! "Navigational aid: [#{kind}] #{name}"
          builder
        end

        ##
        # Fallback type key
        def type_key
          nil
        end
      end

    end
  end
end
