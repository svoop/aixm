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
    #   layer.timetable = AIXM.timetable or nil
    #   layer.selective = true or false (default)
    #   layer.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airspace
    class Layer
      CLASSES = (:A..:G).freeze

      # @return [AIXM::Component::VerticalLimits] vertical limits of this layer
      attr_reader :vertical_limits

      # @return [AIXM::Component::Timetable, nil] activation hours
      attr_reader :timetable

      # @return [String, nil] free text remarks
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

      def timetable=(value)
        fail(ArgumentError, "invalid timetable") unless value.nil? || value.is_a?(AIXM::Component::Timetable)
        @timetable = value
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
        builder << timetable.to_xml(as: :Att) if timetable
        builder.codeSelAvbl(selective? ? 'Y' : 'N') if AIXM.ofmx?
        builder.txtRmk(remarks) if remarks
        builder.target!
      end
    end

  end
end
