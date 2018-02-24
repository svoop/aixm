using AIXM::Refinements

module AIXM
  module Component

    ##
    # Class layers consists of an optional airspace class and mandatory
    # vertical limits.
    class ClassLayer
      CLASSES = %i(A B C D E F G)

      attr_reader :vertical_limits

      def initialize(class: nil, vertical_limits:)
        @klass, @vertical_limits = binding.local_variable_get(:class)&.to_sym, vertical_limits
        fail(ArgumentError, "invalid class `#{@klass}'") unless @klass.nil? || CLASSES.include?(@klass)
        fail(ArgumentError, "invalid vertical limits") unless @vertical_limits.is_a? AIXM::Component::VerticalLimits
      end

      ##
      # Read the airspace class
      #
      # This and other workarounds in the initializer are necessary due to "class"
      # being a reserved keyword in Ruby.
      def class
        @klass
      end

      def to_digest
        [self.class, vertical_limits].to_digest
      end

      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.codeClass(self.class.to_s) if self.class
        builder << vertical_limits.to_xml
        builder.target!   # see https://github.com/jimweirich/builder/issues/42
      end
    end

  end
end
