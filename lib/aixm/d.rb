using AIXM::Refinements

module AIXM

  # Distance or length
  #
  # @example
  #   AIXM.d(123, :m)
  class D
    include Comparable
    extend Forwardable

    UNITS = {
      ft: { km: 0.0003048, m: 0.3048, nm: 0.000164578833554 },
      km: { ft: 3280.839895, m: 1000, nm: 0.539956803 },
      m: { ft: 3.280839895, km: 0.001, nm: 0.000539956803 },
      nm: { ft: 6076.11548554, km: 1.852, m: 1852 }
    }.freeze

    # @!method zero?
    #   @return [Boolean] whether length is zero
    def_delegator :@dist, :zero?

    # @return [Float] distance
    attr_reader :dist

    # @return [Symbol] unit (see {UNITS})
    attr_reader :unit

    def initialize(dist, unit)
      self.dist, self.unit = dist, unit
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "123 m")
    def to_s
      [dist, unit].join(' ')
    end

    def dist=(value)
      fail(ArgumentError, "invalid dist") unless value.is_a?(Numeric) && value >= 0
      @dist = value.to_f
    end

    def unit=(value)
      fail(ArgumentError, "invalid unit") unless value.respond_to? :to_sym
      @unit = value.to_sym.downcase
      fail(ArgumentError, "invalid unit") unless UNITS.has_key? @unit
    end

    # @!method to_ft
    # @!method to_km
    # @!method to_m
    # @!method to_nm
    # @return [AIXM::d] convert distance
    UNITS.each_key do |target_unit|
      define_method "to_#{target_unit}" do
        return self if unit == target_unit
        self.class.new((dist * UNITS[unit][target_unit]).round(8), target_unit)
      end
    end

    # @see Object#<=>
    # @return [Integer]
    def <=>(other)
      to_m.dist <=> other.to_m.dist
    end

    # @see Object#==
    # @return [Boolean]
    def ==(other)
      self.class === other  && (self <=> other).zero?
    end
    alias_method :eql?, :==

    # @see Object#hash
    # @return [Integer]
    def hash
      to_s.hash
    end
  end
end
