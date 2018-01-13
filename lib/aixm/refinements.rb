module AIXM
  module Refinements

    refine Array do
      ##
      # Build 8 character upcase hex digest from payload (one or more strings)
      def to_digest
        ::Digest::MD5.hexdigest(join('|'))[0, 8].upcase
      end
    end

    refine String do
      ##
      # Indent every line of a string with +number+ spaces
      def indent(number)
        whitespace = ' ' * number
        gsub(/^/, whitespace)
      end

      ##
      # Convert DMS angle to DD or +nil+ if the format is not recognized
      #
      # Supported formats:
      # * {-}{DD}D°MM'SS{.SS}"
      # * {-}{DD}D MM SS{.SS}
      # * {-}{DD}DMMSS{.SS}
      def to_dd
        if self =~ /\A(-)?(\d{1,3})[° ]?(\d{2})[' ]?(\d{2}\.?\d{0,2})"?\z/
          ("#{$1}1".to_i * ($2.to_f + ($3.to_f/60) + ($4.to_f/3600))).round(8)
        end
      end
    end

    refine Float do
      ##
      # Convert whole numbers to Integer and leave all other untouched
      def trim
        (self % 1).zero? ? self.to_i : self
      end

      ##
      # Convert DD angle to DMS with the degree zero padded to +padding+ length
      #
      # Output format:
      # * {-}D°MM'SS.SS"
      def to_dms(padding=3)
        minutes = (self.abs % 1) * 60
        seconds = (minutes % 1) * 60
        %Q(%s%0#{padding}d°%02d'%05.2f") % [
          ('-' if self.negative?),
          self.abs.truncate,
          minutes.truncate,
          seconds
        ]
      end
    end
  end
end
