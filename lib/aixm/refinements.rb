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

    # @!method find
    #   Find elements by class and/or attribute values.
    #
    #   The search criteria keys are either:
    #   * +instance_of+ – element is +instance_of?+ given class
    #   * +is_a+ – element +is_a?+ child of given class
    #   * +kind_of+ – instance +is_kind?+ of given class or module
    #   * any other key will match the corresponding attribute reader
    #
    #   @example
    #     array = [
    #       OpenStruct(foo: :bar),
    #       OpenStruct(foo: :bir)
    #     ]
    #     array.find(instance_of: OpenStruct).count   # => 2
    #     array.find(is_a: Object).count              # => 2
    #     array.find(foo: :bar).count                 # => 1
    #     array.find(is_a: Object, foo: :bar).count   # => 1
    #     array.find(is_a: Array).count               # => 0
    #
    #   @note This is a refinement for +Array+
    #   @return [Array<Object>] elements found
    refine Array do
      def find(criteria={})
        select do |element|
          criteria.reduce(true) do |memo, (criterion, value)|
            memo && case criterion
              when :instance_of then element.instance_of? value
              when :is_a then element.is_a? value
              when :kind_of then element.kind_of? value
              else element.send(criterion) == value
            end
          end
        end
      end
    end

    # @!method duplicates
    #   Returns a new array with all elements which appear more than once.
    #
    #   @example
    #     %w(a b c b d e d f b).duplicates   # => ["b", "d"]
    #
    #   @note This is a refinement for +Array+
    #   @return [Array] duplicate elements
    refine Array do
      def duplicates
        group_by(&:itself).select { |_, v| v.size > 1 }.keys
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
      def then_if(condition, &block)
        condition ? self.then(&block) : self
      end
    end

    # @!method decapture
    #   Replace all groups with non-caputuring groups
    #
    #   @example
    #     /^(foo)(?<name>bar)/.decapture   # => /^(?:foo)(?:bar)/
    #
    #   @note This is a refinement for +Regexp+
    refine Regexp do
      def decapture
        Regexp.new(to_s.gsub(/\(\?<\w+>|(?<![^\\]\\)\((?!\?)/, '(?:'))
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
    refine String do
      def inflect(*inflections)
        inflections.inject(self) do |memo, inflection|
          AIXM.config.inflector.send(inflection, memo)
        end
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
          string.gsub!(/(#{UPTRANS_MAP.keys.join('|')})/, UPTRANS_MAP)
          string.unicode_normalize!(:nfd)
          string.gsub!(UPTRANS_FILTER, '')
        end
      end
    end
  end
end
