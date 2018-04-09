using AIXM::Refinements

module AIXM
  class Component

    # Geometries define a 3D airspace horizontally. It's either exactly one
    # circle or at least three points, arcs and borders (the last of which
    # has to be a point with the same coordinates as the first).
    #
    # For a geometry to be valid, it must be comprised of either:
    # * exactly one circle
    # * at least three points, arcs or borders (the last of which a point with
    #   identical coordinates as the first)
    #
    # ===Cheat Sheet in Pseudo Code:
    #   geometry = AIXM.geometry
    #   geometry << AIXM.point or AIXM.arc or AIXM.border or AIXM.circle
    #
    # @example Built by passing elements to the initializer
    #   geometry = AIXM.geometry(
    #     AIXM.point(...),
    #     AIXM.point(...)
    #   )
    #
    # @example Built by adding elements
    #   geometry = AIXM.geometry
    #   geometry << AIXM.point(...)
    #   geometry << AIXM.point(...)
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airspace#avx-border-vertex
    class Geometry
      include Enumerable
      extend Forwardable

      def_delegators :@result_array, :each, :<<

      def initialize(*segments)
        @result_array = segments
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} segments=#{segments.count.inspect}>)
      end

      # @return [Array<AIXM::Component::Geometry::Point,
      #   AIXM::Component::Geometry::Arc,
      #   AIXM::Component::Geometry::Border,
      #   AIXM::Component::Geometry::Circle>] points, arcs, borders or circle
      def segments
        @result_array
      end

      # @return [Boolean] whether the geometry is closed
      def closed?
        circle? || polygon?
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        fail(GeometryError, "geometry is not closed") unless closed?
        @result_array.map { |h| h.to_xml }.join
      end

      private

      def circle?
        @result_array.size == 1 &&
          @result_array.first.is_a?(AIXM::Component::Geometry::Circle)
      end

      def polygon?
        @result_array.size >= 3 &&
          !@result_array.any? { |h| h.is_a?(AIXM::Component::Geometry::Circle) } &&
          @result_array.last.is_a?(AIXM::Component::Geometry::Point) &&
          @result_array.first.xy == @result_array.last.xy
      end
    end

  end
end
