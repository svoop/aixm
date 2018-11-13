using AIXM::Refinements

module AIXM

  # Heading of an aircraft or runway
  #
  # @example
  #   AIXM.h(12)
  #   AIXM.h('12')
  #   AIXM.h('34L')
  #   AIXM.h('05X')
  class H
    SUFFIX_INVERSIONS = {
      R: :L,
      L: :R
    }.freeze

    # @return [Integer] heading
    attr_reader :deg

    # @return [Symbol, nil] suffix
    attr_reader :suffix

    def initialize(deg_and_suffix)
      fail(ArgumentError, "invalid heading") unless deg_and_suffix.to_s =~ /\A(\d+)([A-Z]+)?\z/
      self.deg, self.suffix = $1.to_i, $2
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "05" or "34L")
    def to_s
      [('%02d' % deg), suffix].map(&:to_s).join
    end

    def deg=(value)
      fail(ArgumentError, "invalid deg") unless value.between?(1, 36)
      @deg = value
    end

    def suffix=(value)
      fail(ArgumentError, "invalid suffix") unless value.nil? || value.to_s =~ /\A[A-Z]+\z/
      @suffix = value&.to_s&.to_sym
    end

    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) && deg == other.deg && suffix == other.suffix
    end

    # Invert a heading by 180 degrees
    #
    # @example
    #   AIXM.h('12').invert    # => AIXM.h(30)
    #   AIXM.h('34L').invert   # => AIXM.h(16, 'R')
    #   AIXM.h('33X').invert   # => AIXM.h(17, 'bravo')
    #
    # @return [AIXM::H] inverted heading
    def invert
      AIXM.h([(((deg + 17) % 36) + 1), SUFFIX_INVERSIONS.fetch(suffix, suffix)].join)
    end

    # Check whether +other+ heading is the inverse
    #
    # @example
    #   AIXM.h('12').inverse_of? AIXM.h('30')     # => true
    #   AIXM.h('34L').inverse_of? AIXM.h('16R')   # => true
    #   AIXM.h('16R').inverse_of? AIXM.h('16L')   # => false
    #
    # @return [AIXM::H] inverted heading
    def inverse_of?(other)
      invert == other
    end

  end

end
