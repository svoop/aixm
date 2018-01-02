module AIXM
  module Horizontal
    class Border < Point

      attr_reader :name

      def initialize(xy:, name:)
        super(xy: xy)
        @name = name
      end

    end
  end
end
