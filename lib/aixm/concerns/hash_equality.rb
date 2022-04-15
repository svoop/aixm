using AIXM::Refinements

module AIXM
  module Concerns

    # Implements Hash equality
    module HashEquality

      # @see Object#hash
      def hash
        [self.__class__, to_s].hash
      end

      # @see Object#eql?
      def eql?(other)
        hash == other.hash
      end

    end
  end
end
