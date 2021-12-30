using AIXM::Refinements

module AIXM

  # Rectangle shape composed of two lengths
  #
  # @examples
  #   AIXM.r(AIXM.d(25, :m), AIXM.d(20, :m))   # rectangle
  #   AIXM.r(AIXM.d(25, :m))                   # square
  class R

    # @return [AIXM::D] rectangle length
    attr_reader :length

    # @return [AIXM::D] rectangle width
    attr_reader :width

    def initialize(length, width=nil)
      self.length, self.width = length, (width || length)
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation (e.g. "25.0 m x 20.0 m")
    def to_s
      [length, width].join(' x ')
    end

    %i(length width).each do |dimension|
      define_method("#{dimension}=") do |value|
        fail(ArgumentError, "invalid dimension") unless value.is_a? AIXM::D
        instance_variable_set(:"@#{dimension}", value)
        @length, @width = @width, @length if @length && @width && @length < @width
      end
    end

    # Calculate the surface in square meters
    #
    # @return [Float]
    def surface
      length.to_m.dim * width.to_m.dim
    end

    # @see Object#==
    # @return [Boolean]
    def ==(other)
      self.class === other && length == other.length && width == other.width
    end
    alias_method :eql?, :==

    # @see Object#hash
    # @return [Integer]
    def hash
      to_s.hash
    end

  end

end
