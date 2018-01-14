module AIXM
  class Geometry

    include Enumerable
    extend Forwardable
    using AIXM::Refinements

    def_delegators :@result_array, :each, :<<

    ##
    # Define a shape (horizontal geometry) which is either exactly one
    # +AIXM::Horizontals::Circle+ or any number of +AIXM::Horizontals::Point+,
    # +::Arc+ and +::Border+.
    #
    # Example 1:
    #   geometry = AIXM::Geometry.new(
    #     AIXM::Horizontals::Point(...),
    #     AIXM::Horizontals::Point(...)
    #   )
    #
    # Example 2:
    #   geometry = AIXM::Geometry.new
    #   geometry << AIXM::Horizontals::Point(...)
    #   geometry << AIXM::Horizontals::Point(...)
    def initialize(*horizontals)
      @result_array = horizontals
    end

    ##
    # Array of +AIXM::Horizontal::...+ objects
    def horizontals
      @result_array
    end

    ##
    # Check whether the geometry is valid
    def valid?
      circle? || closed_shape?
    end

    ##
    # Digest to identify the payload
    def to_digest
      horizontals.map(&:to_digest).to_digest
    end

    ##
    # Render AIXM
    #
    # Extensions:
    # * +:OFM+ - Open Flightmaps
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
