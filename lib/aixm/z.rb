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

    # @!method zero?
    #   @return [Boolean] whether height, elevation or altitude is zero
    def_delegator :@alt, :zero?

    # @return [Integer] altitude or elevation value
    attr_reader :alt

    # @return [Symbol] Q code - either +:qfe+ (height in feet), +:qnh+ (altitude in feet or +:qne+ (altitude as flight level)
    attr_reader :code

    def initialize(alt, code)
      self.alt, self.code = alt, code
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "FL045" or "1350 ft QNH")
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

    # @return [Boolean] whether ground level or not
    def ground?
      qfe? && @alt == 0
    end

    # @return [Symbol] unit - either +:fl+ (flight level) or +:ft+ (feet)
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
