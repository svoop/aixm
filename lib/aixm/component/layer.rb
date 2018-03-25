using AIXM::Refinements

module AIXM
  module Component

    ##
    # Each airspace has one or more layers with optional airspace class and
    # mandatory vertical limits.
    #
    # Arguments:
    # * +class+ - optional airspace class (e.g. :C)
    # * +vertical_limits+ - instance of +AIXM::Component::VerticalLimits+
    #
    # Writers:
    # * +schedule+ - instance of +AIXM::Component::Schedule+
    # * +selective+ - +true+ if this class layer can be activated selectively
    #                 or +false+ (default) otherwise
    # * +remarks+ - free text remarks
    class Layer
      CLASSES = (:A..:G)

      attr_reader :vertical_limits, :schedule, :remarks

      def initialize(class: nil, vertical_limits:)
        self.class, self.vertical_limits = binding.local_variable_get(:class), vertical_limits
        @selective = false
      end

      def class=(value)
        @klass = value&.to_sym&.upcase
        fail(ArgumentError, "invalid schedule") unless @klass.nil? || CLASSES.include?(@klass)
      end

      def vertical_limits=(value)
        fail(ArgumentError, "invalid vertical limits") unless value.is_a? AIXM::Component::VerticalLimits
        @vertical_limits = value
      end

      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      def selective=(value)
        fail(ArgumentError, "invalid selective") unless [true, false].include? value
        @selective = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      ##
      # Read the airspace class
      #
      # This and other workarounds in the initializer are necessary due to
      # "class" being a reserved keyword in Ruby.
      def class
        @klass
      end

      ##
      # Whether the layer may be activated selectively
      def selective?
        @selective
      end

      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.codeClass(self.class.to_s) if self.class
        builder << vertical_limits.to_xml
        if schedule
          builder.Att do |att|
            att << schedule.to_xml.indent(2)
          end
        end
        builder.codeSelAvbl(selective? ? 'Y' : 'N') if AIXM.ofmx?
        builder.txtRmk(remarks) if remarks
        builder.target!
      end
    end

  end
end
