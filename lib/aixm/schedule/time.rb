module AIXM
  module Schedule

    # Times suitable for schedules
    #
    # This class implements the bare minimum of stdlib +DateTime+ and adds some
    # extensions:
    # * converts to UTC
    # * date, seconds and milliseconds are ignored
    # * {in?} to check whether schedule time falls within range of schedule times
    #
    # @example
    #   time = AIXM.time('21:30')                          # => 21:30
    #   time.in?(AIXM.time('20:00')..AIXM.time('02:00'))   # => true
    class Time
      extend Forwardable

      EVENTS = %i(sunrise sunset).freeze
      PRECEDENCES = %i(first last).freeze
      DATELESS_DATE = '8888-08-08'

      # Event alternative to the time
      #
      # @return [Symbol, nil] any from {EVENTS}
      attr_reader :event

      # Precedence of time vs. event
      #
      # @return [Symbol, nil] any of {PRECEDENCES}
      attr_reader :precedence

      # Parse the given representation of time.
      #
      # @example
      #   AIXM.time('08:00')
      #   AIXM.time('08:00', or: :sunrise)
      #   AIXM.time('08:00', or: :sunrise, plus: 30)
      #   AIXM.time('08:00', or: :sunrise, minus: 15)
      #   AIXM.time('08:00', or: :sunrise, whichever_comes: :last)
      #
      # @param time [DateTime, Time, String] either stdlib DateTime, stdlib Time,
      #   "HH:MM" (implicitly UTC), "HH:MM [+-]0000" or "HH:MM ZZZ"
      # @param or [Symbol] alternative event from {EVENTS}
      # @param plus [Integer] minutes added to event
      # @param minus [Integer] minutes subtracted from event
      # @param whichever_comes [Symbol] precedence from {PRECEDENCES}
      def initialize(time, or: nil, plus: 0, minus: 0, whichever_comes: :first)
        if self.event = binding.local_variable_get(:or)
          @delta = plus - minus
          self.precedence = whichever_comes or fail ArgumentError
        end
        @datetime = case time.to_s
        when /\A\d{2}:\d{2}\z/
          DateTime.strptime("#{DATELESS_DATE} #{time} +0000", '%F %R %z')
        when /\A\d{2}:\d{2} [+-]\d{4}\z/
          DateTime.strptime("#{DATELESS_DATE} #{time}", '%F %R %z')
        when /\A\d{2}:\d{2} \w+\z/
          DateTime.strptime("#{DATELESS_DATE} #{time}", '%F %R %Z')
        when /\A\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2} ?[+-]\d{2}:?\d{2}\z/
          DateTime.strptime("#{DATELESS_DATE} #{time.strftime('%R %z')}", '%F %R %z')
        else
          fail ArgumentError
        end.new_offset
      end

      # Stdlib DateTime equivalent using the value of {DATELESS_DATE} to represent
      # the ignored date part
      #
      # @return [DateTime]
      def to_datetime
        @datetime
      end

      # Human readable rap like "08:00 UTC or sunrise-15min whichever comes first"
      #
      # @note All formats from {strftime}[https://www.rubydoc.info/stdlib/date/DateTime#strftime-instance_method]
      #   are supported. Additionally +%E+ is replaced with the human readable
      #   event part e.g. "or sunrise-15min whichever comes first".
      #
      # @param format [String] see
      # @return [String]
      def to_s(format='%R UTC %E')
        @datetime.strftime(
          format.sub('%E') do
            ''.tap do |string|
              string << "or #{event}" if event
              string << sprintf("%+dmin", delta) unless delta.zero?
              string << " whichever comes #{precedence}" if precedence
            end
          end
        ).strip
      end

      def inspect
        %Q(#<#{self.class} #{to_s}>)
      end

      # @!method hour
      #   @return [Integer]
      # @!method minute
      #   @return [Integer]
      def_delegators :to_datetime, :hour, :minute

      # Minutes added or subtracted from event
      #
      # @return [Integer]
      def delta
        @delta || 0
      end

      # Whether this schedule time is comparable to others.
      #
      # @return [Boolean]
      def comparable?
        !event
      end

      # Whether this schedule time falls within the given range of schedule
      # times.
      #
      # @param range [Range<AIXM::Schedule::Time>] range of schedule times
      # @return [Boolean]
      def in?(range)
        fail "not comparable" unless comparable? && range.first.comparable? && range.last.comparable?
        if range.min
          range.first.to_s <= self.to_s && self.to_s <= range.last.to_s
        else
          range.first.to_s <= self.to_s || self.to_s <= range.last.to_s
        end
      end

      private

      def event=(value)
        fail ArgumentError if value && !EVENTS.include?(value)
        @event = value
      end

      def precedence=(value)
        fail ArgumentError if value && !PRECEDENCES.include?(value)
        @precedence = value
      end

      def <=>(other)
        @datetime <=> other.to_datetime
      end
    end

  end
end
