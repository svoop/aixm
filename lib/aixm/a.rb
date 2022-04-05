using AIXM::Refinements

module AIXM

  # Angle in the range of -360 < angle < 360 degrees (used for azimuths or
  # courses) and with an optional one-letter suffix (used for runways).
  #
  # @example Initialization
  #   AIXM.a(-36.9)   # => #<AIXM::A -36.9° "32">
  #   AIXM.a(12)      # => #<AIXM::A 12° "01">
  #   AIXM.a("12L")   # => #<AIXM::A 120° "12L">
  #   AIXM.a(360)     # => #<AIXM::A 0° "36">
  #   AIXM.a(-400)    # => #<AIXM::A -40° "32">
  #
  # @example Calculations
  #   a = AIXM.a("02L")
  #   a += 5               # => #<AIXM::A 25° "03L">
  #   a -= AIXM.a(342.8)   # => #<AIXM::A -317.8° "04L">
  #   a.to_s               # => "-317.8°"
  #   a.to_s(:runway)      # => "04L"
  #   a.to_s(:bearing)     # => "042.2000"
  #   a.to_f               # => 42.2
  #   a.to_i               # => 42
  #   a.invert             # => #<AIXM::A -137.8° "22R">
  #   a.to_s(:runway)      # => "22R"
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

    # See the {overview}[AIXM::A] for examples.
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
      %Q(#<#{self.class} #{to_s} #{to_s(:runway).inspect}>)
    end

    # @return [Integer] within 0..359
    def to_i
      (deg.round + 360) % 360
    end

    # @return [Float] within 0.0..359.9~
    def to_f
      ((deg + 360) % 360).to_f
    end

    # Degrees as formatted string
    #
    # Types are:
    # * :human - degrees within -359.9~..359.9~ as D.D° (default)
    # * :bearing - degrees within 0.0..359.9~ as DDD.DDDD
    # * :runway - degrees within "01".."36" plus optional suffix
    #
    # @param type [Symbol, nil] either :runway, :bearing or nil
    # @param unit [String] unit to postfix
    # @return [String]
    def to_s(type=:human)
      return '' unless deg
      case type
        when :runway then [('%02d' % (((deg / 10).round + 35) % 36 + 1)), suffix].join
        when :bearing then '%08.4f' % to_f.round(4)
        when :human then [deg.to_s('F').sub(/\.0$/, ''), '°'].join
        else fail ArgumentError
      end
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
