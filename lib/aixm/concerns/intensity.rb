using AIXM::Refinements

module AIXM
  module Concerns

    # Adds optional intensity of lights to features.
    module Intensity

      INTENSITIES = {
        LIL: :low,
        LIM: :medium,
        LIH: :high,
        OTHER: :other   # specify in remarks
      }.freeze

      # Intensity of lights
      #
      # @overload remarks
      #   @return [AIXM::Component::Timetable, nil] any of {INTENSITIES}
      # @overload remarks=(value)
      #   @param value [AIXM::Component::Timetable, nil] any of {INTENSITIES}
      attr_reader :intensity

      def intensity=(value)
        @intensity = value.nil? ? nil : INTENSITIES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid intensity")
      end

    end
  end
end
