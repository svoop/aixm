module AIXM
  module Feature
    module NavigationalAid

      ##
      # Implements common attributes of all navigational aids
      #
      # Please note that the optional elevation +z+ must be in +:qnh+.
      class Base < AIXM::Component::Base
        using AIXM::Refinements

        attr_reader :id, :name, :xy, :z
        attr_accessor :remarks

        private_class_method :new

        def initialize(id:, name:, xy:, z: nil)
          @id, @name, @xy, @z = id&.upcase, name&.upcase, xy, z
          fail(ArgumentError, "invalid xy") unless xy.is_a? AIXM::XY
          fail(ArgumentError, "invalid z") unless z.nil? || (z.is_a?(AIXM::Z) && z.qnh?)
        end

        ##
        # Return either the +type_key+ or +class+
        def kind
          respond_to?(:type_key) ? type_key : self.class.name.split('::').last.to_sym
        end

        ##
        # Digest to identify the payload
        def to_digest
          [kind, id, name, xy.to_digest, z&.to_digest, remarks].to_digest
        end

        ##
        # Create builder to render AIXM in subclasses
        def to_builder(*extensions)
          @format = extensions >> :OFM ? :OFM : :AIXM
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.comment! "Navigational aid: [#{kind}] #{name}"
          builder
        end
      end

    end
  end
end
