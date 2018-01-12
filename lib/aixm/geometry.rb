module AIXM
  class Geometry

    include Enumerable
    extend Forwardable
    using AIXM::Refinements

    def_delegators :@result_array, :each, :<<

    def initialize(*horizontals)
      @result_array = horizontals
    end

    def horizontals
      @result_array
    end

    def valid?
      circle? || closed_shape?
    end

    ##
    # Digest to identify the payload
    def to_digest
      horizontals.map(&:to_digest).to_digest
    end

    def to_xml(*extensions)
      @result_array.map { |h| h.to_xml(extensions) }.join
    end

    private

    def circle?
      @result_array.size == 1 &&
        @result_array.first.is_a?(AIXM::Horizontal::Circle)
    end

    def closed_shape?
      @result_array.size >= 3 &&
        !@result_array.any? { |h| h.is_a?(AIXM::Horizontal::Circle) } &&
        @result_array.last.is_a?(AIXM::Horizontal::Point) &&
        @result_array.first.xy == @result_array.last.xy
    end

  end
end
