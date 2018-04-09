using AIXM::Refinements

module AIXM
  class Component

    # Each airspace has one or more layers with optional airspace class and
    # mandatory vertical limits.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   layer = AIXM.layer(
    #     class: String or nil
    #     vertical_limits: AIXM.vertical_limits
    #   )
    #   layer.schedule = AIXM.schedule or nil
    #   layer.selective = true or false (default)
    #   layer.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airspace
    class Layer
      CLASSES = (:A..:G)

      # @return [AIXM::Component::VerticalLimits] vertical limits of this layer
      attr_reader :vertical_limits

      # @return [AIXM::Component::Schedule, nil] activation hours
      attr_reader :schedule

      # @return [String] free text remarks
      attr_reader :remarks

      def initialize(class: nil, vertical_limits:)
        self.class = binding.local_variable_get(:class)
        self.vertical_limits = vertical_limits
        self.selective = false
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} class=#{@klass.inspect}>)
      end

      # @!attribute class
      # @return [Symbol] class of layer (see {CLASSES})
      def class
        @klass
      end

      def class=(value)
        @klass = value&.to_sym&.upcase
        fail(ArgumentError, "invalid class") unless @klass.nil? || CLASSES.include?(@klass)
      end

      def vertical_limits=(value)
        fail(ArgumentError, "invalid vertical limits") unless value.is_a? AIXM::Component::VerticalLimits
        @vertical_limits = value
      end

      def schedule=(value)
        fail(ArgumentError, "invalid schedule") unless value.nil? || value.is_a?(AIXM::Component::Schedule)
        @schedule = value
      end

      # @!attribute [w] selective
      # @return [Boolean] whether the layer may be activated selectively
      def selective?
        @selective
      end

      def selective=(value)
        fail(ArgumentError, "invalid selective") unless [true, false].include? value
        @selective = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] AIXM or OFMX markup
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
