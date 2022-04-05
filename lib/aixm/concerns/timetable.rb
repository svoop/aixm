module AIXM
  module Concerns

    # Adds optional timetable to features.
    module Timetable

      # Operating hours
      #
      # @overload remarks
      #   @return [AIXM::Component::Timetable, nil]
      # @overload remarks=(value)
      #   @param value [AIXM::Component::Timetable, nil]
      attr_reader :timetable

      def timetable=(value)
        fail(ArgumentError, "invalid timetable") unless value.nil? || value.is_a?(AIXM::Component::Timetable)
        @timetable = value
      end

    end
  end
end
