using AIXM::Refinements

module AIXM

  ##
  # Elevation or altitude
  #
  # The following Q codes are recognized:
  # * +:qfe+ - height in feet
  # * +:qnh+ - altitude in feet
  # * +:qne+ - altitude as flight level
  class Z
    CODES = %i(qfe qnh qne).freeze

    attr_reader :alt, :code

    def initialize(alt, code)
      self.alt, self.code = alt, code
    end

    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    def to_s
      qne? ? "FL%03i" % alt : [alt, unit, code.upcase].join(' ')
    end

    def alt=(value)
      fail(ArgumentError, "invalid alt") unless value.is_a? Numeric
      @alt = value.to_i
    end

    def code=(value)
      fail(ArgumentError, "invalid code") unless value.respond_to? :to_sym
      @code = value.to_sym.downcase
      fail(ArgumentError, "invalid code") unless CODES.include? @code
    end

    ##
    # Check whether two elevations/altitudes are equivalent
    def ==(other)
      other.is_a?(Z) && alt == other.alt && code == other.code
    end

    ##
    # Check Q code
    #
    # Example:
    #   z.qnh?   # => true
    #   z.qfe?   # => false
    CODES.each do |code|
      define_method(:"#{code}?") { @code == code }
    end

    ##
    # Whether on ground level
    def ground?
      qfe? && @alt == 0
    end

    ##
    # Get the elevation/altitude base
    #
    # Values:
    # * +:ASFC: - above surface
    # * +:AMSL: - above mean sea level
    def base
      qfe? ? :ASFC : :AMSL
    end

    ##
    # Get the unit
    #
    # Values:
    # * +:FL+ - flight level
    # * +:FT+ - feet
    def unit
      qne? ? :FL : :FT
    end

  end

end
