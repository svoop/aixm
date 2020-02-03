module AIXM

  # @abstract
  class Feature
    REGION_RE = /\A[A-Z]{2}\z/.freeze

    private_class_method :new

    # @return [String] reference to source of the feature data
    attr_reader :source

    # @return [String] OFMX region all features in this document belong to
    attr_reader :region

    def initialize(source: nil, region: nil)
      self.source = source
      self.region = region || AIXM.config.region
    end

    def source=(value)
      fail(ArgumentError, "invalid source") unless value.nil? || value.is_a?(String)
      @source = value
    end

    def region=(value)
      fail(ArgumentError, "invalid region") unless value.nil? || (value.is_a?(String) && value.upcase.match?(REGION_RE))
      @region = value&.upcase
    end

    # @return [Boolean]
    def ==(other)
      self.__class__ === other && self.to_uid == other.to_uid
    end
  end

end
