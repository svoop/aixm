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

    # @!method to_digest
    #   Builds a 4 byte hex digest from the Array payload.
    #
    #   @example
    #     ['foo', :bar, nil, [123]].to_digest
    #     # => "f3920098"
    #
    #   @note This is a refinement for +Array+
    #   @return [String] 4 byte hex
    refine Array do
      def to_digest
        ::Digest::SHA512.hexdigest(flatten.map(&:to_s).join('|'))[0, 8]
      end
    end

    # @!method to_uuid
    #   Builds a UUID version 3 digest from the Array payload.
    #
    #   @example
    #     ['foo', :bar, nil, [123]].to_uuid
    #     # => "f3920098"
    #
    #   @note This is a refinement for +Array+
    #   @return [String] UUID version 3
    refine Array do
      def to_uuid
        ::Digest::MD5.hexdigest(flatten.map(&:to_s).join('|')).unpack("a8a4a4a4a12").join("-")
      end
    end


    # @!method to_dms(padding=3)
    #   Convert DD angle to DMS with the degrees zero padded to +padding+
    #   length.
    #
    #   @example
    #     43.22164444444445.to_dms(2)
    #     # => "43°12'77.92\""
    #     43.22164444444445.to_dms
    #     # => "043°12'77.92\""
    #
    #   @note This is a refinement for +Float+
    #   @param padding [Integer] number of digits for the degree part
    #   @return [String] angle in DMS notation +{-}D°MM'SS.SS"+
    refine Float do
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
    end

    # @!method to_rad
    #   Convert an angle from degree to radian.
    #
    #   @example
    #     45.to_rad
    #     # => 0.7853981633974483
    #
    #   @note This is a refinement for +Float+
    #   @return [Float] radian angle
    refine Float do
      def to_rad
        self * Math::PI / 180
      end
    end

    # @!method trim
    #   Convert whole numbers to Integer and leave all other untouched.
    #
    #   @example
    #     3.0.trim
    #     # => 3
    #     3.3.trim
    #     # => 3.3
    #
    #   @note This is a refinement for +Float+
    #   @return [Integer, Float] converted Float
    refine Float do
      def trim
        (self % 1).zero? ? self.to_i : self
      end
    end

    # @!method lookup(key_or_value, fallback=omitted=true)
    #   Fetch a value from the hash, but unlike +Hash#fetch+, if +key_or_value+
    #   is no hash key, check whether +key_or_value+ is a hash value and if so
    #   return it.
    #
    #   @example
    #     h = { one: 1, two: 2, three: 3, four: :three }
    #     h.lookup(:one)              # => 1
    #     h.lookup(1)                 # => 1
    #     h.lookup(:three)            # => 3 (key has priority over value)
    #     h.lookup(:foo)              # => KeyError
    #     h.lookup(:foo, :fallback)   # => :fallback
    #     h.lookup(:foo, nil)         # => nil
    #
    #   @note This is a refinement for +Hash+
    #   @param key_or_value [Object] key or value of the hash
    #   @param fallback [Object] fallback value
    #   @raise [KeyError] if neither a matching hash key nor hash value are
    #     found and no fallback value has been passed
    refine Hash do
      def lookup(key_or_value, fallback=omitted=true)
        self[key_or_value] ||
          (key_or_value if has_value?(key_or_value)) ||
          (omitted ? fail(KeyError, "key or value `#{key_or_value}' not found") : fallback)
      end
    end

    # @!method indent(number)
    #   Indent every line of a string with +number+ spaces.
    #
    #   @example
    #     "foo\nbar".indent(2)
    #     # => "  foo\n  bar"
    #
    #   @note This is a refinement for +String+
    #   @param number [Integer] number of spaces
    #   @return [String] line indended string
    refine String do
      def indent(number)
        whitespace = ' ' * number
        gsub(/^/, whitespace)
      end
    end

    # @!method to_dd
    #   Convert DMS angle to DD or +nil+ if the notation is not recognized.
    #
    #   @example
    #     %q(43°12'77.92").to_dd
    #     # => 43.22164444444445
    #     %q(-123).to_dd
    #     # => nil
    #
    #   Supported notations:
    #   * +{-}{DD}D°MM'SS{.SS}"+
    #   * +{-}{DD}D MM SS{.SS}+
    #   * +{-}{DD}DMMSS{.SS}+
    #
    #   @note This is a refinement for +String+
    #   @return [Float] angle in DD notation
    refine String do
      def to_dd
        if self =~ /\A(-)?(\d{1,3})[° ]?(\d{2})[' ]?(\d{2}\.?\d{0,2})"?\z/
          ("#{$1}1".to_i * ($2.to_f + ($3.to_f/60) + ($4.to_f/3600)))
        end
      end
    end

    # @!method to_time
    #   Parse string to date and time.
    #
    #   @example
    #     '2018-01-01 15:00'.to_time
    #     # => 2018-01-01 15:00:00 +0100
    #
    #   @note This is a refinement for +String+
    #   @return [Time] date and time
    refine String do
      def to_time
        Time.parse(self)
      end
    end

    # @!method uptrans
    #   Upcase and transliterate to match the reduced character set for
    #   AIXM names and titles.
    #
    #   See {UPTRANS_MAP} for supported diacryts and {UPTRANS_FILTER} for the
    #   list of allowed characters in the returned value.
    #
    #   @example
    #     "Nîmes-Alès".uptrans
    #     # => "NIMES-ALES"
    #     "Zürich".uptrans
    #     # => "ZUERICH"
    #
    #   @note This is a refinement for +String+
    #   @return [String] upcased and transliterated String
    refine String do
      def uptrans
        self.dup.tap do |string|
          string.upcase!
          string.gsub!(/(#{UPTRANS_MAP.keys.join('|')})/, UPTRANS_MAP)
          string.unicode_normalize!(:nfd)
          string.gsub!(UPTRANS_FILTER, '')
        end
      end
    end
  end
end
