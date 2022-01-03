using AIXM::Refinements

module AIXM

  # Angle in the range of -360 < angle < 360 degrees (used for azimuths or
  # courses) and with an optional one-letter suffix (used for runways).
  #
  # @example Initialization
  #   AIXM.a(-36.9)   # (-36.9°)
  #   AIXM.a(12)      # (12°)
  #   AIXM.a("12L")   # (120° suffix "L")
  #   AIXM.a(360)     # (0°)
  #   AIXM.a(-400)    # (-40°)
  #
  # @example Calculations
  #   a = AIXM.a("12L")
  #   a += 20              # (140° suffix "L")
  #   a -= AIXM.a(162.8)   # (-22.8° suffix "L")
  #   a.to_s               # => "-22.8°"
  #   a.to_bearing         # => 337.2
  #   a.to_course          # => 337
  #   a.to_runway          # => "34L"
  #   a.invert             # (157.2° suffix "R")
  #   a.invert.to_runway   # => "16R"
  class A
    SUFFIX_INVERSIONS = {
      R: :L,
      L: :R
    }.freeze

    RUNWAY_RE = /\A(0[1-9]|[12]\d|3[0-6])([A-Z])?\z/

    # @return [Integer] angle in the range of -360 < angle < 360
    attr_reader :deg

    # @return [Symbol, nil] one-letter suffix
    attr_reader :suffix

    def initialize(value)
      case value
      when String
        fail(ArgumentError, "invalid angle") unless value =~ RUNWAY_RE
        self.deg, self.suffix = $1.to_i * 10, $2
      when Numeric
        self.deg = value
      else
        fail(ArgumentError, "invalid angle")
      end
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s} #{to_runway.inspect}>)
    end

    # Degrees as formatted string
    #
    # @param round [Integer] number of decimals to round
    # @param unit [String] unit to postfix
    # @return [String]
    def to_s(round: 4, unit: '°')
      deg ? [deg.round(round).to_s('F').sub(/\.0$/, ''), unit].join  : ''
    end

    # Degrees as bearing
    #
    # @return [Float] within 0.0000..359.9999
    def to_bearing
      ((deg.round(4) + 360) % 360).to_f
    end

    # Degrees as course (positive Integer)
    #
    # @return [Integer] within 0..359
    def to_course(round: 0)
      (deg.round + 360) % 360
    end

    # Degrees and suffix as runway
    #
    # @return [String] within "01".."36" plus optional suffix
    def to_runway
      deg ? [('%02d' % (((deg / 10).round + 35) % 36 + 1)), suffix].join : ''
    end

    def deg=(value)
      fail(ArgumentError, "invalid deg `#{value}'") unless value.is_a? Numeric
      normalized_value = value.abs % 360
      sign = '-' if value.negative? && normalized_value.nonzero?
      @deg = BigDecimal("#{sign}#{normalized_value}")
    end

    def suffix=(value)
      fail(ArgumentError, "invalid suffix") unless value.nil? || value.to_s =~ /\A[A-Z]\z/
      @suffix = value&.to_s&.to_sym
    end

    # Invert an angle by 180 degrees
    #
    # @example
    #   AIXM.a(120).invert     # (300°)
    #   AIXM.a("34L").invert   # (160° suffix "R")
    #
    # @return [AIXM::A] inverted angle
    def invert
      self.class.new(deg.negative? ? deg - 180 : deg + 180).tap do |angle|
        angle.suffix = SUFFIX_INVERSIONS.fetch(suffix, suffix)
      end
    end

    # Check whether +other+ angle is the inverse
    #
    # @example
    #   AIXM.a(120).inverse_of? AIXM.a(300)       # => true
    #   AIXM.a("34L").inverse_of? AIXM.a("16R")   # => true
    #   AIXM.a("33X").inverse_of? AIXM.a("33X")   # => true
    #   AIXM.a("16R").inverse_of? AIXM.a("16L")   # => false
    #
    # @return [Boolean] whether the inverted angle or not
    def inverse_of?(other)
      invert == other
    end

    # Negate degrees
    #
    # @return [AIXM::A]
    def -@
      deg.zero? ? self : self.class.new(-deg).tap { _1.suffix = suffix }
    end

    # Add degrees
    #
    # @param value [Numeric, AIXM::A]
    # @return [AIXM::A]
    def +(value)
      case value
      when Numeric
        value.zero? ? self : self.class.new(deg + value).tap { _1.suffix = suffix }
      when AIXM::A
        value.deg.zero? ? self : self.class.new(deg + value.deg).tap { _1.suffix = suffix }
      else
        fail ArgumentError
      end
    end

    # Subtract degrees
    #
    # @param value [Numeric, AIXM::A]
    # @return [AIXM::A]
    def -(value)
      self + -value
    end

    # @see Object#==
    # @return [Boolean]
    def ==(other)
      self.class === other  && deg == other.deg && suffix == other.suffix
    end
    alias_method :eql?, :==

    # @see Object#hash
    # @return [Integer]
    def hash
      [deg, suffix].join.hash
    end
  end

end
