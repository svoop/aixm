module AIXM
  module Feature
    class Base
      attr_reader :source

      private_class_method :new

      def initialize(source: nil, region: nil)
        self.source, self.region = source, region
      end

      ##
      # Source the feature data is coming from
      def source=(value)
        fail(ArgumentError, "invalid source") unless value.nil? || value.is_a?(String)
        @source = value
      end

      ##
      # Region the feature belongs to (falls back to +AIXM.config.region+)
      def region=(value)
        fail(ArgumentError, "invalid region") unless value.nil? || value.is_a?(String)
        @region = value&.upcase
      end

      def region
        @region || AIXM.config.region&.upcase
      end

    end
  end
end
