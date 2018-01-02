module AIXM
  class Geometry

    include Enumerable
    extend Forwardable

    def_delegators :@result_array, :each, :<<

    def initialize(*horizontals)
      @result_array = horizontals
    end

    def closed?
      @result_array.first.is_a?(AIXM::Horizontal::Point) &&
        @result_array.last.is_a?(AIXM::Horizontal::Point) &&
        @result_array.first.xy == @result_array.last.xy
    end

  end
end
