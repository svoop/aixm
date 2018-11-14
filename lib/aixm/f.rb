using AIXM::Refinements

module AIXM

  # Radio frequency for communication, navigation and so forth.
  #
  # @example
  #   AIXM.f(123.35, :mhz)
  class F
    UNITS = %i(ghz mhz khz).freeze

    # @return [Float] frequency
    attr_reader :freq

    # @return [Symbol] unit (see {UNITS})
    attr_reader :unit

    def initialize(freq, unit)
      self.freq, self.unit = freq, unit
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "123.35 mhz")
    def to_s
      [freq, unit].join(' ')
    end

    def freq=(value)
      fail(ArgumentError, "invalid freq") unless value.is_a? Numeric
      @freq = value.to_f
    end

    def unit=(value)
      fail(ArgumentError, "invalid unit") unless value.respond_to? :to_sym
      @unit = value.to_sym.downcase
      fail(ArgumentError, "invalid unit") unless UNITS.include? @unit
    end

    # @return [Boolean] whether this frequency is part of a frequency band
    def between?(lower_freq, upper_freq, unit)
      freq.between?(lower_freq, upper_freq) && self.unit == unit
    end

    # @see Object#==
    # @return [Boolean]
    def ==(other)
      self.class === other && freq == other.freq && unit == other.unit
    end
    alias_method :eql?, :==

    # @see Object#hash
    # @return [Integer]
    def hash
      to_s.hash
    end

  end

end
