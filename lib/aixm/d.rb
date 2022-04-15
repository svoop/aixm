using AIXM::Refinements

module AIXM

  # Dimension, distance or length
  #
  # @example
  #   AIXM.d(123, :m)
  class D
    include AIXM::Concerns::HashEquality
    include Comparable
    extend Forwardable

    UNITS = {
      ft: { km: 0.0003048, m: 0.3048, nm: 0.000164578833554 },
      km: { ft: 3280.839895, m: 1000, nm: 0.539956803 },
      m: { ft: 3.280839895, km: 0.001, nm: 0.000539956803 },
      nm: { ft: 6076.11548554, km: 1.852, m: 1852 }
    }.freeze

    # Whether dimension is zero.
    #
    # @!method zero?
    # @return [Boolean]
    def_delegator :@dim, :zero?

    # Dimension
    #
    # @overload dim
    #   @return [Float]
    # @overload dim=(value)
    #   @param value [Float]
    attr_reader :dim

    # Unit
    #
    # @overload unit
    #   @return [Symbol] any of {UNITS}
    # @overload unit=(value)
    #   @param value [Symbol] any of {UNITS}
    attr_reader :unit

    # See the {overview}[AIXM::D] for examples.
    def initialize(dim, unit)
      self.dim, self.unit = dim, unit
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "123.0 m")
    def to_s
      [dim, unit].join(' '.freeze)
    end

    def dim=(value)
      fail(ArgumentError, "invalid dim") unless value.is_a?(Numeric) && value >= 0
      @dim = value.to_f
    end

    def unit=(value)
      fail(ArgumentError, "invalid unit") unless value.respond_to? :to_sym
      @unit = value.to_sym.downcase
      fail(ArgumentError, "invalid unit") unless UNITS.has_key? @unit
    end

    # Convert dimension
    #
    # @!method to_ft
    # @!method to_km
    # @!method to_m
    # @!method to_nm
    # @return [AIXM::D] converted dimension
    UNITS.each_key do |target_unit|
      define_method "to_#{target_unit}" do
        return self if unit == target_unit
        self.class.new((dim * UNITS[unit][target_unit]).round(8), target_unit)
      end
    end

    # @see Object#<=>
    def <=>(other)
      dim <=> other.send(:"to_#{unit}").dim
    end

    # @see Object#==
    def ==(other)
      self.class === other  && (self <=> other).zero?
    end
  end
end
