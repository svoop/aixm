using AIXM::Refinements

module AIXM
  module Component

    ##
    # Geometries define a 3D airspace horizontally. It's either exactly one
    # circle or at least three points, arcs and borders (the last of which
    # has to be a point with the same coordinates as the first).
    #
    # Example 1:
    #   geometry = AIXM.geometry(
    #     AIXM.point(...),
    #     AIXM.point(...)
    #   )
    #
    # Example 2:
    #   geometry = AIXM.geometry
    #   geometry << AIXM.point(...)
    #   geometry << AIXM.point(...)
    class Geometry
      include Enumerable
      extend Forwardable

      def_delegators :@result_array, :each, :<<

      def initialize(*segments)
        @result_array = segments
      end

      ##
      # Array of +AIXM::Component::Geometry::...+ objects
      def segments
        @result_array
      end

      ##
      # Check whether the geometry is complete
      def complete?
        circle? || closed_shape?
      end

      ##
      # Digest to identify the payload
      def to_digest
        segments.map(&:to_digest).to_digest
      end

      ##
      # Render XML
      def to_xml
        @result_array.map { |h| h.to_xml }.join
      end

      private

      def circle?
        @result_array.size == 1 &&
          @result_array.first.is_a?(AIXM::Component::Geometry::Circle)
      end

      def closed_shape?
        @result_array.size >= 3 &&
          !@result_array.any? { |h| h.is_a?(AIXM::Component::Geometry::Circle) } &&
          @result_array.last.is_a?(AIXM::Component::Geometry::Point) &&
          @result_array.first.xy == @result_array.last.xy
      end
    end

  end
end
