module AIXM
  module Horizontal
    class Point

      attr_reader :xy

      def initialize(xy:)
        fail(ArgumentError, "invalid xy") unless xy.is_a? AIXM::XY
        @xy = xy
      end

    end
  end
end
