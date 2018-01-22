module AIXM

  ##
  # Frequency
  #
  # The following units are recognized:
  # * +:MHZ+ - megahertz
  # * +:KHZ+ - kilohertz
  class F

    UNITS = %i(MHZ KHZ).freeze

    attr_reader :freq, :unit

    def initialize(freq, unit)
      @freq, @unit = freq.to_f, unit&.to_sym&.upcase
      fail(ArgumentError, "unrecognized unit `#{@unit}'") unless UNITS.include? @unit
    end

    def ==(other)
      other.is_a?(F) && freq == other.freq && unit == other.unit
    end

  end

end
