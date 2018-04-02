module AIXM
  module Feature
    class Base
      private_class_method :new

      def initialize(region: nil)
        self.region = region
      end

      ##
      # Set the region the feature belongs to
      def region=(value)
        fail(ArgumentError, "invalid region") unless value.nil? || value.is_a?(String)
        @region = value&.upcase
      end

      ##
      # Get the region (falls back to +AIXM.config.region+)
      def region
        @region || AIXM.config.region&.upcase
      end

    end
  end
end
