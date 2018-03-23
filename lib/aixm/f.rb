using AIXM::Refinements

module AIXM

  ##
  # Frequency
  #
  # The following units are recognized:
  # * +:mhz+ - megahertz
  # * +:khz+ - kilohertz
  class F
    UNITS = %i(mhz khz).freeze

    attr_reader :freq, :unit

    def initialize(freq, unit)
      @freq, @unit = freq.to_f, unit&.to_sym&.downcase
      fail(ArgumentError, "unrecognized unit `#{@unit}'") unless UNITS.include? @unit
    end

    ##
    # Check whether two frequencies are identical
    def ==(other)
      other.is_a?(F) && freq == other.freq && unit == other.unit
    end

    ##
    # Check whether this frequency is part of a frequency band
    def between?(lower_freq, upper_freq, unit)
      freq.between?(lower_freq, upper_freq) && self.unit == unit
    end

  end

end
