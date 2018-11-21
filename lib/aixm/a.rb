using AIXM::Refinements

module AIXM

  # Angle from 0 to 359 degrees with an optional suffix used for azimuths,
  # bearings, headings, courses etc.
  #
  # @example Initialized with Numeric
  #   a = AIXM.a(12)   # 12 degrees, 1 degree precision, no suffix
  #   a.precision      # => 3 (three digits = steps of 1 degree)
  #   a.to_s           # => "012"
  #   a.suffix         # => nil
  #   a.deg            # => 12
  #   a.deg += 7       # => 19
  #   a.deg += 341     # => 0     - deg is always within (0..359)
  #   a.to_s           # => "000" - to_s is always within ("000".."359")
  #
  # @example Initialized with String
  #   a = AIXM.a('06L')   # 60 degrees, 10 degree precision, suffix :L
  #   a.precision         # => 2 (two digits = steps of 10 degrees)
  #   a.to_s              # => "06L"
  #   a.suffix            # => :L
  #   a.deg               # => 60
  #   a.deg += 7          # => 70
  #   a.deg += 190        # => 0     - deg is always within (0..359)
  #   a.to_s              # => "36L" - to_s converts to ("01".."36")
  class A
    SUFFIX_INVERSIONS = {
      R: :L,
      L: :R
    }.freeze

    # @return [Integer] angle
    attr_reader :deg

    # @return [Integer] precision: +2+ (10 degree steps) or +3+ (1 degree steps)
    attr_reader :precision

    # @return [Symbol, nil] suffix
    attr_reader :suffix

    def initialize(deg_and_suffix)
      case deg_and_suffix
      when Numeric
        self.deg, @precision = deg_and_suffix, 3
      when String
        fail(ArgumentError, "invalid angle") unless deg_and_suffix.to_s =~ /\A(\d+)([A-Z]+)?\z/
        self.deg, @precision, self.suffix = $1.to_i * 10, 2, $2
      when Symbol   # used only by private build method
        fail(ArgumentError, "invalid precision") unless %i(2 3).include? deg_and_suffix
        @deg, @precision = 0, deg_and_suffix.to_s.to_i
      else
        fail(ArgumentError, "invalid angle")
      end
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class}[precision=#{precision}] #{to_s}>)
    end

    # @return [String] human readable representation according to precision
    def to_s
      if precision == 2
        [('%02d' % ((deg / 10 + 35) % 36 + 1)), suffix].map(&:to_s).join
      else
        ('%03d' % deg)
      end
    end

    def deg=(value)
      fail(ArgumentError, "invalid deg `#{value}'") unless value.is_a?(Numeric) && value.round.between?(0, 360)
      @deg = (precision == 2 ? (value.to_f / 10).round * 10 : value.round) % 360
    end

    def suffix=(value)
      fail(RuntimeError, "suffix only allowed when precision is 2") unless value.nil? || precision == 2
      fail(ArgumentError, "invalid suffix") unless value.nil? || value.to_s =~ /\A[A-Z]+\z/
      @suffix = value&.to_s&.to_sym
    end

    # Invert an angle by 180 degrees
    #
    # @example
    #   AIXM.a(120).invert     # => AIXM.a(300)
    #   AIXM.a("34L").invert   # => AIXM.a("16R")
    #   AIXM.a("33X").invert   # => AIXM.a("33X")
    #
    # @return [AIXM::A] inverted angle
    def invert
      build(precision: precision, deg: (deg + 180) % 360, suffix: SUFFIX_INVERSIONS.fetch(suffix, suffix))
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

    # Add degrees
    #
    # @return [AIXM::A]
    def +(numeric_or_angle)
      fail ArgumentError unless numeric_or_angle.respond_to? :round
      build(precision: precision, deg: (deg + numeric_or_angle.round) % 360, suffix: suffix)
    end

    # Subtract degrees
    #
    # @return [AIXM::A]
    def -(numeric_or_angle)
      fail ArgumentError unless numeric_or_angle.respond_to? :round
      build(precision: precision, deg: (deg - numeric_or_angle.round + 360) % 360, suffix: suffix)
    end

    # @private
    def round
      deg
    end

    # @see Object#==
    # @return [Boolean]
    def ==(other)
      self.class === other  && deg == other.deg && precision == other.precision && suffix == other.suffix
    end
    alias_method :eql?, :==

    # @see Object#hash
    # @return [Integer]
    def hash
      to_s.hash
    end

    private

    def build(precision:, deg:, suffix: nil)
      self.class.new(precision.to_s.to_sym).tap do |a|
        a.deg = deg
        a.suffix = suffix
      end
    end
  end

end
