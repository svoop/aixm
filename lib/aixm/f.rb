using AIXM::Refinements

module AIXM

  # Radio frequency for communication, navigation and so forth.
  #
  # @example
  #   AIXM.f(123.35, :mhz)
  class F
    include AIXM::Concerns::HashEquality
    extend Forwardable

    UNITS = %i(ghz mhz khz).freeze

    # @!method zero?
    #   @return [Boolean] whether frequency is zero
    def_delegator :@freq, :zero?

    # Frequency
    #
    # @overload freq
    #   @return [Float]
    # @overload freq=(value)
    #   @param value [Float]
    attr_reader :freq

    # Unit
    #
    # @overload unit
    #   @return [Symbol] any of {UNITS}
    # @overload unit=(value)
    #   @param value [Symbol] any of {UNITS}
    attr_reader :unit

    # See the {overview}[AIXM::F] for examples.
    def initialize(freq, unit)
      self.freq, self.unit = freq, unit
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "123.35 mhz")
    def to_s
      [freq, unit].join(' '.freeze)
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

    # Whether this frequency is part of a frequency band.
    #
    # @return [Boolean]
    def between?(lower_freq, upper_freq, unit)
      freq.between?(lower_freq, upper_freq) && self.unit == unit
    end

    # @see Object#==
    def ==(other)
      self.class === other && freq == other.freq && unit == other.unit
    end

    # Whether this frequency is part of the voice airband for civil aviation
    # using +AIXM.config.voice_channel_separation+.
    #
    # @return [Boolean]
    def voice?
      return false unless unit == :mhz
      case AIXM.config.voice_channel_separation
        when 25 then voice_25?
        when 833 then voice_833?
        when :any then voice_25? || voice_833?
        else fail(ArgumentError, "unknown voice channel separation")
      end
    end

    # Whether this frequency is for emergencies only.
    #
    # @return [Boolean]
    def voice_emergency?
      self == AIXM::EMERGENCY
    end

    private

    # Whether this frequency is part of the voice airband for civil aviation
    # using 25 kHz channel separation.
    #
    # @return [Boolean]
    def voice_25?
      return false unless unit == :mhz && freq == freq.round(3) && freq.between?(118, 136.975)
      ((freq * 1000).round % 25).zero?
    end

    # Whether this frequency is part of the voice airband for civil aviation
    # using 8.33 kHz channel separation.
    #
    # @return [Boolean]
    def voice_833?
      return false unless unit == :mhz && freq == freq.round(3) && freq.between?(118, 136.99)
      [0.005, 0.01, 0.015].any? { |d| (((freq - d) * 1000).round % 25).zero? }
    end

  end

end
