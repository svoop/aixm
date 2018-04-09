module AIXM

  # @abstract
  class Feature
    private_class_method :new

    # @return [String] reference to source of the feature data
    attr_reader :source

    def initialize(source: nil, region: nil)
      self.source, self.region = source, region
    end

    # @return [String] reference to source of the feature data
    def source=(value)
      fail(ArgumentError, "invalid source") unless value.nil? || value.is_a?(String)
      @source = value
    end

    # @!attribute region
    # @note When assigning +nil+, the global default +AIXM.config.region+ is written instead.
    # @return [String] region the feature belongs to
    def region
      @region || AIXM.config.region&.upcase
    end

    def region=(value)
      fail(ArgumentError, "invalid region") unless value.nil? || value.is_a?(String)
      @region = value&.upcase
    end

    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) && self.to_uid == other.to_uid
    end
  end

end
