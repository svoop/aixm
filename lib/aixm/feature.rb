using AIXM::Refinements

module AIXM

  # @abstract
  class Feature < Component

    REGION_RE = /\A[A-Z]{2}\z/.freeze

    private_class_method :new

    # Freely usable XML comment e.g. to include raw source data
    #
    # @overload comment
    #   @return [String]
    # @overload comment=(value)
    #   @param value [Object]
    attr_reader :comment

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

    def comment=(value)
      @comment = value.to_s.strip
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
      self.__class__ === other && self.to_uid.to_s == other.to_uid.to_s
    end

    # @see Object#eql?
    def hash
      [self.__class__, to_uid.to_s].hash
    end

    protected

    # @return [String]
    def indented_comment
      if comment.include?("\n")
        [nil, comment.indent(4), '  '].join("\n")
      else
        comment.dress
      end
    end
  end

end
