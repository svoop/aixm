module AIXM
  module Horizontal
    class Arc < Point

      attr_reader :center_xy

      def initialize(xy:, center_xy:, clockwise:)
        super(xy: xy)
        fail(ArgumentError, "invalid center xy") unless center_xy.is_a? AIXM::XY
        fail(ArgumentError, "clockwise must be true or false") unless [true, false].include? clockwise
        @center_xy, @clockwise = center_xy, clockwise
      end

      def clockwise?
        @clockwise
      end

    end
  end
end
