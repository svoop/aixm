module AIXM

  # @abstract
  class Feature
    include AIXM::Concerns::HashEquality

    REGION_RE = /\A[A-Z]{2}\z/.freeze

    private_class_method :new

    # Freely usable e.g. to find_by foreign keys.
    #
    # @return [Object]
    attr_accessor :meta

    # Reference to source of the feature data.
    #
    # @overload source
    #   @return [String]
    # @overload source=(value)
    #   @param value [String]
    attr_reader :source

    # OFMX region all features in this document belong to.
    #
    # @overload region
    #   @return [String]
    # @overload region=(value)
    #   @param value [String]
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

    # @see Object#==
    def ==(other)
      self.__class__ === other && self.to_uid == other.to_uid
    end

    # @see Object#eql?
    def hash
      [self.__class__, to_uid].hash
    end
  end

end
