module AIXM
  module Refinements

    UPTRANS_FILTER = %r(
      [^A-Z0-9, !"&#$%'\(\)\*\+\-\./:;<=>\?@\[\\\]\^_\|\{\}]
    )x.freeze

    UPTRANS_MAP = {
      'Ä' => 'AE',
      'Ö' => 'OE',
      'Ü' => 'UE',
      'Æ' => 'AE',
      'Œ' => 'OE',
      "Å" => "Aa",
      "Ø" => "Oe"
    }.freeze

    PRETTY_XSLT = <<~END.then { Nokogiri::XSLT(_1) }
      <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
        <xsl:strip-space elements="*"/>
        <xsl:template match="/">
          <xsl:copy-of select="."/>
        </xsl:template>
      </xsl:stylesheet>
    END

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
        ::Digest::SHA512.hexdigest(flatten.map(&:to_s).join('|'.freeze))[0, 8]
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
    #   @return [Object]
    #   @raise [KeyError] if neither a matching hash key nor hash value are
    #     found and no fallback value has been passed
    refine Hash do
      def lookup(key_or_value, fallback=omitted=true)
        self[key_or_value] ||
          (key_or_value if has_value?(key_or_value)) ||
          (omitted ? fail(KeyError, "key or value `#{key_or_value}' not found") : fallback)
      end
    end

    # @!method pretty
    #   Transform the XML document to be pretty when sending +to_xml+
    #
    #   @example
    #     xml = <<~END
    #       <xml><aaa> AAA </aaa>
    #         <bbb/>
    #         <ccc   foo="bar"  >
    #           CCC
    #         </ccc>
    #       </xml>
    #     END
    #     Nokogiri.XML(xml).pretty.to_xml
    #     # => <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    #          <xml>
    #            <aaa> AAA </aaa>
    #            <bbb/>
    #            <ccc foo="bar">
    #              CCC
    #            </ccc>
    #          </xml>
    #
    #   @note This is a refinement for +Nokogiri::XML::Document+
    #   @return [Nokogiri::XML::Document]
    refine Nokogiri::XML::Document do
      def pretty
        PRETTY_XSLT.transform(self)
      end
    end

    # @!method then_if
    #   Same as +Object#then+ but only applied if the condition is true.
    #
    #   @example
    #     "foobar".then_if(false) { _1.gsub(/o/, 'i') }   # => "foobar"
    #     "foobar".then_if(true) { _1.gsub(/o/, 'i') }    # => "fiibar"
    #
    #   @note This is a refinement for +Object+
    #   @return [Object]
    refine Object do
      def then_if(condition, &block)   # TODO: [ruby-3.1] use anonymous block "&" on this and next line
        condition ? self.then(&block) : self
      end
    end

    # @!method Range.from
    #   Returns a Range covering the given object.
    #
    #   To ease coverage tests in mixed arrays of single objects and object
    #   ranges, this method assures you're always dealing with objects. It
    #   returns self if it is already a Range, otherwise builds one with the
    #   given single object as both beginning and end.
    #
    #   @example
    #     Range.from(5)      # => (5..5)
    #     Range.from(1..3)   # => (1..3)
    #
    #   @note This is a refinement for +Range+
    #   @param object [Object]
    #   @return [Range]
    #refine Range do
    refine Range.singleton_class do
      def from(object)
        object.is_a?(Range) ? object : (object..object)
      end
    end

    # @!method decapture
    #   Replace all groups with non-caputuring groups
    #
    #   @example
    #     /^(foo)(?<name>bar)/.decapture   # => /^(?:foo)(?:bar)/
    #
    #   @note This is a refinement for +Regexp+
    #   @return [Regexp]
    refine Regexp do
      def decapture
        Regexp.new(to_s.gsub(/\(\?<\w+>|(?<![^\\]\\)\((?!\?)/, '(?:'))
      end
    end

    # @!method dress
    #   Prepends and appends the given +string+ after stripping +self+. Quite
    #   the contrary of +strip+, hence the name.
    #
    #   @example
    #     "     foobar\n\n".dress   # => " foobar "
    #
    #   @note This is a refinement for +String+
    #   @param padding [String] string to prepend and append
    #   @return [String]
    refine String do
      def dress(padding=' ')
        [padding, strip, padding].join
      end
    end

    # @!method to_class
    #   Convert string to class
    #
    #   @example
    #     "AIXM::Feature::NavigationalAid".to_class
    #     # => AIXM::Feature::NavigationalAid
    #
    #   @note This is a refinement for +String+
    #   @return [Class]
    refine String do
      def to_class
        Object.const_get(self)
      end
    end

    # @!method inflect
    #   Apply inflections from the +dry-inflector+ gem
    #
    #   @example
    #     s = "AIXM::Feature::NavigationalAid"
    #     s.inflect(:demodulize, :tableize, :pluralize)
    #     # => "navigational_aids"
    #
    #   @see https://www.rubydoc.info/gems/dry-inflector
    #   @note This is a refinement for +String+
    #   @return [String]
    refine String do
      def inflect(*inflections)
        inflections.inject(self) do |memo, inflection|
          AIXM.config.inflector.send(inflection, memo)
        end
      end
    end

    # @!method compact
    #   Collapse whitespace to one space, but leave +\n+ untouched, then strip
    #   what's left.
    #
    #   @example
    #     "  foo\n\nbar  baz \r".compact   # => "foo\n\nbar baz"
    #
    #   @note This is a refinement for +String+
    #   @return [String] compacted string
    refine String do
      def compact
        split("\n").map { _1.gsub(/\s+/, ' ') }.join("\n").strip
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
    #     "431277.92S".to_dd
    #     # => -43.22164444444445
    #     %q(-123).to_dd
    #     # => nil
    #
    #   Supported notations:
    #   * +{-}{DD}D°MM'SS{.SS}"{[NESW]}+
    #   * +{-}{DD}D MM SS{.SS} {[NESW]}+
    #   * +{-}{DD}DMMSS{.SS}[NESW]+
    #
    #   Quite a number of typos are tolerated such as the wrong use of
    #   minute +'+ and second +"+ markers as well as the use of decimal
    #   comma +,+ instead of dot +.+.
    #
    #   @note This is a refinement for +String+
    #   @return [Float] angle in DD notation
    refine String do
      def to_dd
        if match = self.match(DMS_RE)
          "#{match['sgn']}1".to_i * "#{:- if match['hem_sw']}1".to_i * (
            match['deg'].to_f +
            match['min'].to_f/60 +
            match['sec'].tr(',', '.').to_f/3600
          )
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
          string.gsub!(/(#{UPTRANS_MAP.keys.join('|'.freeze)})/, UPTRANS_MAP)
          string.unicode_normalize!(:nfd)
          string.gsub!(UPTRANS_FILTER, '')
        end
      end
    end
  end
end
