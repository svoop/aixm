using AIXM::Refinements

module AIXM

  ##
  # Frequency
  #
  # Arguments:
  # * +freq+ - frequency
  # * +unit+ - either +:ghz+, +:mhz+ or +:khz+
  class F
    UNITS = %i(ghz mhz khz).freeze

    attr_reader :freq, :unit

    def initialize(freq, unit)
      self.freq, self.unit = freq, unit
    end

    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

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

    ##
    # Check whether two frequencies are identical
    def ==(other)
      other.is_a?(self.class) && freq == other.freq && unit == other.unit
    end

    ##
    # Check whether this frequency is part of a frequency band
    def between?(lower_freq, upper_freq, unit)
      freq.between?(lower_freq, upper_freq) && self.unit == unit
    end

  end

end
