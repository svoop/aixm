module AIXM
  module Concerns

    # Adds optional free text remarks to features.
    module Remarks

      # Free text remarks
      #
      # @overload remarks
      #   @return [String, nil]
      # @overload remarks=(value)
      #   @param value [String, nil]
      attr_reader :remarks

      def remarks=(value)
        @remarks = value&.to_s
      end

    end
  end
end
