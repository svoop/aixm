module AIXM
  module Horizontal
    class Circle

      attr_reader :center_xy, :radius

      def initialize(center_xy:, radius:)
        fail(ArgumentError, "invalid center xy") unless center_xy.is_a? AIXM::XY
        @center_xy, @radius = center_xy, radius
      end

    end
  end
end
