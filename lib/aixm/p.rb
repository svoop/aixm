using AIXM::Refinements

module AIXM

  # Pressure
  #
  # @example
  #   AIXM.d(14, :bar)
  class P
    include Comparable
    extend Forwardable

    UNITS = {
      p: { mpa: 0.000001, psi: 0.000145037738, bar: 0.00001, torr: 0.0075006 },
      mpa: { p: 1_000_000, psi: 145.037738, bar: 10, torr: 7500.6 },
      psi: { p: 6894.75729, mpa: 0.00689475729, bar: 0.0689475729, torr: 51.714816529374 },
      bar: { p: 100000, mpa: 0.1, psi: 14.5037738, torr: 750.06 },
      torr: { p: 133.322, mpa: 0.000133322, psi: 0.019336721305636, bar: 0.00133322 }
    }.freeze

    # @!method zero?
    #   @return [Boolean] whether pressure is zero
    def_delegator :@pres, :zero?

    # @return [Float] pressure
    attr_reader :pres

    # @return [Symbol] unit (see {UNITS})
    attr_reader :unit

    def initialize(pres, unit)
      self.pres, self.unit = pres, unit
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "14 bar")
    def to_s
      [pres, unit].join(' ')
    end

    def pres=(value)
      fail(ArgumentError, "invalid pres") unless value.is_a?(Numeric) && value >= 0
      @pres = value.to_f
    end

    def unit=(value)
      fail(ArgumentError, "invalid unit") unless value.respond_to? :to_sym
      @unit = value.to_sym.downcase
      fail(ArgumentError, "invalid unit") unless UNITS.has_key? @unit
    end

    # @!method to_p
    # @!method to_mpa
    # @!method to_psi
    # @!method to_bar
    # @!method to_torr
    #
    # @return [AIXM::P] convert pressure
    UNITS.each_key do |target_unit|
      define_method "to_#{target_unit}" do
        return self if unit == target_unit
        self.class.new((pres * UNITS[unit][target_unit]).round(8), target_unit)
      end
    end

    # @see Object#<=>
    # @return [Integer]
    def <=>(other)
      pres <=> other.send(:"to_#{unit}").pres
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
