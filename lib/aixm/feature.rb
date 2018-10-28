module AIXM

  # @abstract
  class Feature
    private_class_method :new

    # @return [String] reference to source of the feature data
    attr_reader :source

    def initialize(source: nil)
      self.source = source
    end

    # @return [String] reference to source of the feature data
    def source=(value)
      fail(ArgumentError, "invalid source") unless value.nil? || value.is_a?(String)
      @source = value
    end

    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) && self.to_uid == other.to_uid
    end
  end

end
