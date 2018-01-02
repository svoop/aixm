module AIXM

  ##
  # Elevation or altitude
  #
  # The following Q codes are recognized:
  # * QFE - height in feet
  # * QNH - altitude in feet
  # * QNE - altitude as flight level
  class Z

    CODES = %i(QFE QNH QNE)

    attr_reader :alt, :code

    def initialize(alt:, code:)
      fail(ArgumentError, "unrecognized Q code `#{code}'") unless CODES.include? code
      @alt, @code = alt, code
    end

    def ==(other)
      other.is_a?(Z) && alt == other.alt && code == other.code
    end

    def ground?
      @code == :QFE && @alt == 0
    end

    def base
      @code == :QFE ? :ASFC : :AMSL
    end

  end

end
