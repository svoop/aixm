module AIXM
  module Concerns

    # Adds optional markings to features.
    module Marking

      # Markings
      #
      # @overload remarks
      #   @return [String, nil]
      # @overload remarks=(value)
      #   @param value [String, nil]
      attr_reader :marking

      def marking=(value)
        @marking = value&.to_s
      end

    end
  end
end
