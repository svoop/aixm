using AIXM::Refinements

module AIXM

  # Height, elevation or altitude
  #
  # @example
  #   AIXM.z(1000, :qfe)   # height (ft): 1000 ft above ground
  #   AIXM.z(2000, :qnh)   # elevation or altitude (ft): 2000 ft above mean sea level
  #   AIXM.z(45, :qne)     # altitude: flight level 45
  #
  # ===Shortcuts:
  # * +AIXM::GROUND+ - surface expressed as "0 ft QFE"
  # * +AIXM::UNLIMITED+ - no upper limit expressed as "FL 999"
  class Z
    extend Forwardable

    CODES = %i(qfe qnh qne).freeze

    # Whether height, elevation or altitude is zero.

    # @!method zero?
    # @return [Boolean]
    def_delegator :@alt, :zero?

    # Altitude or elevation value.
    #
    # @overload alt
    #   @return [Integer]
    # @overload alt=(value)
    #   @param value [Integer]
    attr_reader :alt

    # Q code
    #
    # @overload code
    #   @return [Symbol] either +:qfe+ (height in feet), +:qnh+ (altitude in
    #     feet or +:qne+ (altitude as flight level)
    # @overload code=(value)
    #   @param value [Symbol] either +:qfe+ (height in feet), +:qnh+ (altitude
    #     in feet or +:qne+ (altitude as flight level)
    attr_reader :code

    # See the {overview}[AIXM::Z] for examples.
    def initialize(alt, code)
      self.alt, self.code = alt, code
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "FL045" or "1350 ft QNH")
    def to_s
      qne? ? "FL%03i" % alt : [alt, unit, code.upcase].join(' '.freeze)
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

    # Whether QFE, QNH or QNE.
    #
    # @example
    #   z = AIXM.z(123, :qnh)
    #   z.qnh?   # => true
    #   z.qfe?   # => false
    #
    # @!method qfe?
    # @!method qnh?
    # @!method qne?
    # @return [Boolean]
    CODES.each do |code|
      define_method(:"#{code}?") { @code == code }
    end

    # Whether ground level
    #
    # @return [Boolean]
    def ground?
      qfe? && @alt == 0
    end

    # Unit
    # @return [Symbol] either +:fl+ (flight level) or +:ft+ (feet)
    def unit
      qne? ? :fl : :ft
    end

    # @see Object#==
    # @return [Boolean]
    def ==(other)
      self.class === other && alt == other.alt && code == other.code
    end
    alias_method :eql?, :==

    # @see Object#hash
    # @return [Integer]
    def hash
      to_s.hash
    end

  end

end
