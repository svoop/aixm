module AIXM

  ##
  # Elevation or altitude
  #
  # The following Q codes are recognized:
  # * +:qfe+ - height in feet
  # * +:qnh+ - altitude in feet
  # * +:qne+ - altitude as flight level
  class Z
    using AIXM::Refinements

    CODES = %i(qfe qnh qne).freeze

    attr_reader :alt, :code

    def initialize(alt, code)
      @alt, @code = alt, code&.to_sym&.downcase
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
      qfe? && @alt == 0
    end

    def base
      qfe? ? :ASFC : :AMSL
    end

    def unit
      qne? ? :FL : :FT
    end

  end

end
