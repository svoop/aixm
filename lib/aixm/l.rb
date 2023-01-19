module AIXM

  # Geographical line with optional profile
  #
  # Each line point is an OStruct which can be queried for its coordinates with
  # `.xy` or its optional elevation with `.z`
  #
  # @example All of the below are equivalent
  #   line = AIXM.l   # or:
  #   line = AIXM.l(xy: AIXM.xy(...), z: AIXM.z(...))
  #   line.add_line_point(xy: AIXM.xy(...), z: AIXM.z(...))
  #   line.line_points.first.xy   # => AIXM::XY
  #   line.line_points.first.z    # => AIXM::Z
  class L

    # Array of line points
    #
    # @return [Array<OStruct>]
    attr_reader :line_points

    # See the {overview}[AIXM::L] for examples.
    def initialize(xy: nil, z: nil)
      @line_points = []
      add_line_point(xy: xy, z: z) if xy
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation
    def to_s
      line_points.map { _1.to_h.values.map(&:to_s).join(' ') }.join(', ')
    end

    # Add a line point to the line
    #
    # @param xy [AIXM::XY] coordinates
    # @param z [AIXM::Z, nil] elevation
    # @return [self]
    def add_line_point(xy:, z: nil)
      fail(ArgumentError, "invalid xy") unless xy.instance_of?(AIXM::XY)
      fail(ArgumentError, "invalid z") unless !z || z.instance_of?(AIXM::Z)
      line_points << OpenStruct.new(xy: xy, z: z)
      self
    end

    # Whether there are enough line points to define a line
    #
    # @return [Boolean]
    def line?
      line_points.count >= 2
    end

    # @see Object#==
    def ==(other)
      self.class === other && to_s == other.to_s
    end
  end
end
