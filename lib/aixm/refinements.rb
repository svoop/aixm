module AIXM
  module Refinements

    refine Array do
      ##
      # Build 8 character hex digest from payload (one or more strings)
      def to_digest
        ::Digest::MD5.hexdigest(join('|'))[0, 8]
      end
    end

    refine String do
      ##
      # Indent every line of a string with +number+ spaces
      def indent(number)
        whitespace = ' ' * number
        gsub(/^/, whitespace)
      end
    end

  end
end
