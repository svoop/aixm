module AIXM

  ##
  # Elevation or altitude
  #
  # The following Q codes are recognized:
  # * QFE - height in feet
  # * QNH - altitude in feet
  # * QNE - altitude as flight level
  class Z
    using AIXM::Refinements

    CODES = %i(QFE QNH QNE).freeze

    attr_reader :alt, :code

    def initialize(alt, code)
      @alt, @code = alt, code&.to_sym&.upcase
      fail(ArgumentError, "unrecognized Q code `#{code}'") unless CODES.include? @code
    end

    ##
    # Digest to identify the payload
    def to_digest
      [alt, code].to_digest
    end

    def ==(other)
      other.is_a?(Z) && alt == other.alt && code == other.code
    end

    CODES.each do |code|
      define_method(:"#{code}?") { @code == code }
    end

    def ground?
      QFE? && @alt == 0
    end

    def base
      QFE? ? :ASFC : :AMSL
    end

    def unit
      QNE? ? :FL : :FT
    end

  end

end
