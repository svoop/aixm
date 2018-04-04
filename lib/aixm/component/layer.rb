using AIXM::Refinements

module AIXM
  module Component

    ##
    # Each airspace has one or more layers with optional airspace class and
    # mandatory vertical limits.
    #
    # Arguments:
    # * +class+ - optional airspace class
    # * +vertical_limits+ - instance of +AIXM::Component::VerticalLimits+
    class Layer
      CLASSES = (:A..:G)

      attr_reader :vertical_limits
      attr_reader :schedule, :remarks

      def initialize(class: nil, vertical_limits:)
        self.class = binding.local_variable_get(:class)
        self.vertical_limits = vertical_limits
        @selective = false
      end

      def inspect
        %Q(#<#{self.class} class=#{@klass.inspect}>)
      end

      ##
      # Airspace class from :A to :G
      def class=(value)
        @klass = value&.to_sym&.upcase
        fail(ArgumentError, "invalid class") unless @klass.nil? || CLASSES.include?(@klass)
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
      # Vertical limits as instance of +AIXM::Component::VerticalLimits+
      def vertical_limits=(value)
        fail(ArgumentError, "invalid vertical limits") unless value.is_a? AIXM::Component::VerticalLimits
        @vertical_limits = value
      end

      ##
      # Schedule as instance of +AIXM::Component::Schedule+
      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      ##
      # May be activated selectively (true or false)
      def selective=(value)
        fail(ArgumentError, "invalid selective") unless [true, false].include? value
        @selective = value
      end

      ##
      # Free text remarks
      def remarks=(value)
        @remarks = value&.to_s
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
        builder << schedule.to_xml(as: :Att) if schedule
        builder.codeSelAvbl(selective? ? 'Y' : 'N') if AIXM.ofmx?
        builder.txtRmk(remarks) if remarks
        builder.target!
      end
    end

  end
end
