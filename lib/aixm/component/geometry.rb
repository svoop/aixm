using AIXM::Refinements

module AIXM
  class Component

    # Geometries define a 3D airspace horizontally.
    #
    # For a geometry to be valid, it must be comprised of either:
    # * exactly one point
    # * exactly one circle
    # * at least three points, arcs or borders (the last of which a point with
    #   identical coordinates as the first)
    #
    # ===Cheat Sheet in Pseudo Code:
    #   geometry = AIXM.geometry
    #   geometry.add_segment(AIXM.point or AIXM.arc or AIXM.border or AIXM.circle)
    #
    # @example Built by passing elements to the initializer
    #   geometry = AIXM.geometry(
    #     AIXM.point(...),
    #     AIXM.point(...)
    #   )
    #
    # @example Built by adding segments
    #   geometry = AIXM.geometry
    #   geometry.add_segment(AIXM.point(...))
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airspace#avx-border-vertex
    class Geometry
      include AIXM::Association

      # @!method segments
      #   @return [Array<AIXM::Component::Geometry::Point,
      #     AIXM::Component::Geometry::Arc,
      #     AIXM::Component::Geometry::Border,
      #     AIXM::Component::Geometry::Circle>] points, arcs, borders or circle
      # @!method add_segment
      #   @param [AIXM::Component::Geometry::Point,
      #     AIXM::Component::Geometry::Arc,
      #     AIXM::Component::Geometry::Border,
      #     AIXM::Component::Geometry::Circle]
      #   @return [self]
      has_many :segments, accept: %i(point arc border circle)

      # @!method airspace
      #   @return [AIXM::Feature::Airspace] airspace the geometry defines
      belongs_to :airspace

      def initialize(*segments)
        segments.each { |s| add_segment(s) }
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} segments=#{segments.count.inspect}>)
      end

      # @return [Boolean] whether the geometry is closed
      def closed?
        point? || circle? || polygon?
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        fail(GeometryError.new("geometry is not closed", self)) unless closed?
        segments.map { |h| h.to_xml }.join
      end

      private

      def point?
        segments.size == 1 &&
          segments.first.is_a?(AIXM::Component::Geometry::Point)
      end

      def circle?
        segments.size == 1 &&
          segments.first.is_a?(AIXM::Component::Geometry::Circle)
      end

      def polygon?
        segments.size >= 3 &&
          !segments.any? { |h| h.is_a?(AIXM::Component::Geometry::Circle) } &&
          segments.last.is_a?(AIXM::Component::Geometry::Point) &&
          segments.first.xy == segments.last.xy
      end
    end

  end
end
