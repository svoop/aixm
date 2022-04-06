using AIXM::Refinements

module AIXM

  # Weight
  #
  # @example
  #   AIXM.w(2.9, :t)
  class W
    include Comparable
    extend Forwardable

    UNITS = {
      kg: { t: 0.001, lb: 2.204622622, ton: 0.00110231131 },
      t: { kg: 1000, lb: 2204.622622, ton: 1.10231131 },
      lb: { kg: 0.45359237, t: 0.00045359237, ton: 0.000499999999581 },
      ton: { kg: 907.18474, t: 0.90718474, lb: 2000.00000013718828 }
    }.freeze

    # Whether weight is zero.
    #
    # @!method zero?
    # @return [Boolean]
    def_delegator :@wgt, :zero?

    # Weight
    #
    # @overload wgt
    #   @return [Float]
    # @overload wgt=(value)
    #   @param value [Float]
    attr_reader :wgt

    # Unit
    #
    # @overload unit
    #   @return [Float] any of {UNITS}
    # @overload unit=(value)
    #   @param value [Float] any of {UNITS}
    attr_reader :unit

    # See the {overview}[AIXM::W] for examples.
    def initialize(wgt, unit)
      self.wgt, self.unit = wgt, unit
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "123 t")
    def to_s
      [wgt, unit].join(' '.freeze)
    end

    def wgt=(value)
      fail(ArgumentError, "invalid wgt") unless value.is_a?(Numeric) && value >= 0
      @wgt = value.to_f
    end

    def unit=(value)
      fail(ArgumentError, "invalid unit") unless value.respond_to? :to_sym
      @unit = value.to_sym.downcase
      fail(ArgumentError, "invalid unit") unless UNITS.has_key? @unit
    end

    # Convert weight
    #
    # @!method to_kg
    # @!method to_t
    # @!method to_lb
    # @!method to_ton
    # @return [AIXM::W] converted weight
    UNITS.each_key do |target_unit|
      define_method "to_#{target_unit}" do
        return self if unit == target_unit
        self.class.new((wgt * UNITS[unit][target_unit]).round(8), target_unit)
      end
    end

    # @see Object#<=>
    # @return [Integer]
    def <=>(other)
      wgt <=> other.send(:"to_#{unit}").wgt
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
