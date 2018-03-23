module AIXM
  module Refinements

    UPTRANS_FILTER = %r{[^A-Z0-9, !"&#$%'\(\)\*\+\-\./:;<=>\?@\[\\\]\^_\|\{\}]}.freeze

    UPTRANS_MAP = {
      'Ä' => 'AE',
      'Ö' => 'OE',
      'Ü' => 'UE',
      'Æ' => 'AE',
      'Œ' => 'OE',
      "Å" => "Aa",
      "Ø" => "Oe"
    }.freeze

    KM_FACTORS = {
      km: 1,
      m: 0.001,
      nm: 1.852,
      ft: 0.0003048
    }.freeze

    refine Array do
      ##
      # Build a 4 byte hex digest
      def to_digest
        ::Digest::SHA512.hexdigest(flatten.map(&:to_s).join('|'))[0, 8]
      end
    end

    refine Hash do
      ##
      # Fetch a value from the hash, but unlike +fetch+, if +key_or_value+ is
      # no hash key, check whether +key_or_value+ is a hash value and if so
      # return it.
      #
      # Examples:
      #   h = { one: 1, two: 2, three: 3, four: :three }
      #   h.lookup(:one)             # => 1
      #   h.lookup(1)                # => 1
      #   h.lookup(:three)           # => 3 (key has priority over value)
      #   h.lookup(:foo)             # => KeyError
      #   h.lookup(:foo, :default)   # => :default
      #   h.lookup(:foo, nil)        # => nil
      def lookup(key_or_value, default = omitted = true)
        self[key_or_value] ||
          (key_or_value if has_value?(key_or_value)) ||
          (omitted ? fail(KeyError, "key or value `#{key_or_value}' not found") : default)
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
      # Upcase and transliterate to match the reduced character set for
      # AIXM names and titles
      def uptrans
        self.dup.tap do |string|
          string.upcase!
          string.gsub!(/(#{UPTRANS_MAP.keys.join('|')})/, UPTRANS_MAP)
          string.unicode_normalize!(:nfd)
          string.gsub!(UPTRANS_FILTER, '')
        end
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
          ("#{$1}1".to_i * ($2.to_f + ($3.to_f/60) + ($4.to_f/3600)))
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
      # Convert an angle from degree to radian
      def to_rad
        self * Math::PI / 180
      end

      ##
      # Convert DD angle to DMS with the degrees zero padded to +padding+ length
      #
      # Output format:
      # * {-}D°MM'SS.SS"
      def to_dms(padding=3)
        degrees = self.abs.floor
        minutes = ((self.abs - degrees) * 60).floor
        seconds = (self.abs - degrees - minutes.to_f / 60) * 3600
        minutes, seconds = minutes + 1, 0 if seconds.round(2) == 60
        degrees, minutes = degrees + 1, 0 if minutes == 60
        %Q(%s%0#{padding}d°%02d'%05.2f") % [
          ('-' if self.negative?),
          self.abs.truncate,
          minutes.abs.truncate,
          seconds.abs
        ]
      end

      ##
      # Convert a distance +from+ unit (+:km+, +:m+, +:nm+ or +:ft+) to kilometers
      def to_km(from:)
        self * KM_FACTORS.fetch(from.downcase.to_sym)
      rescue KeyError
        raise(ArgumentError, "unit `#{from}' not supported")
      end
    end
  end
end
