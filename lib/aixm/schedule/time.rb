module AIXM
  module Schedule

    # Times suitable for schedules
    #
    # This class implements the bare minimum of stdlib +Time+ and adds some
    # extensions:
    #
    # * converts to UTC
    # * date, seconds and milliseconds are ignored
    # * {in?} to check whether schedule time falls within range of times
    #
    # @example
    #   time = AIXM.time('21:30')                          # => 21:30
    #   time.in?(AIXM.time('20:00')..AIXM.time('02:00'))   # => true
    class Time
      extend Forwardable

      EVENTS = %i(sunrise sunset).freeze
      PRECEDENCES = %i(first last).freeze
      DATELESS_DATE = '0000-01-01'.freeze

      # Event or alternative to time
      #
      # @return [Symbol, nil] any from {EVENTS}
      attr_reader :event

      # Minutes added or subtracted from event
      #
      # @return [Integer, nil]
      attr_reader :delta

      # Precedence of time vs. event
      #
      # @return [Symbol, nil] any of {PRECEDENCES}
      attr_reader :precedence

      # Parse the given representation of time.
      #
      # @example
      #   AIXM.time('08:00')
      #   AIXM.time(:sunrise)
      #   AIXM.time(:sunrise, plus: 30)
      #   AIXM.time('08:00', or: :sunrise)
      #   AIXM.time('08:00', or: :sunrise, plus: 30)
      #   AIXM.time('08:00', or: :sunrise, minus: 15)
      #   AIXM.time('08:00', or: :sunrise, whichever_comes: :last)
      #
      # @param time_or_event [Time, DateTime, String, Symbol] either time as
      #   stdlib Time or DateTime, "HH:MM" (implicitly UTC), "HH:MM [+-]00:00",
      #   "HH:MM UTC" or event from {EVENTS} as Symbol
      # @param or [Symbol] alternative event from {EVENTS}
      # @param plus [Integer] minutes added to event
      # @param minus [Integer] minutes subtracted from event
      # @param whichever_comes [Symbol] precedence from {PRECEDENCES}
      def initialize(time_or_event, or: nil, plus: 0, minus: 0, whichever_comes: :first)
        alternative_event = binding.local_variable_get(:or)   # necessary since "or" is a keyword
        @time = @event = @precedence = nil
        case time_or_event
        when Symbol
          self.event = time_or_event
        when ::Time, DateTime
          time_or_event = time_or_event.to_time
          set_time(time_or_event.hour, time_or_event.min, time_or_event.utc_offset)
        when /\A(\d{2}):?(\d{2}) ?([+-]\d{2}:?\d{2}|UTC)?\z/
          set_time($1, $2, $3)
        else
          fail(ArgumentError, "time or event not recognized")
        end
        fail(ArgumentError, "only one event allowed") if event && alternative_event
        self.event ||= alternative_event
        @delta = event ? plus - minus : 0
        if @time && event
          self.precedence = whichever_comes
          fail(ArgumentError, "mandatory precedence missing") unless precedence
        end
      end

      # Human readable rap like "08:00 UTC or sunrise-15min whichever comes first"
      #
      # @note All formats from {strftime}[https://www.rubydoc.info/stdlib/date/DateTime#strftime-instance_method]
      #   are supported. Additionally +%E+ is replaced with the human readable
      #   event part e.g. "or sunrise-15min whichever comes first".
      #
      # @param format [String] see {strftime}[https://www.rubydoc.info/stdlib/date/DateTime#strftime-instance_method]
      # @return [String]
      def to_s(format='%R UTC %E')
        return event.to_s unless @time
        @time.strftime(
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

      # Stdlib Time equivalent using the value of {DATELESS_DATE} to represent a
      # time only.
      #
      # @return [Time]
      def to_time
        @time
      end

      # @!method hour
      #   @return [Integer]
      # @!method min
      #   @return [Integer]
      def_delegators :@time, :hour, :min

      # Whether two times are equal.
      #
      # @return [Boolean]
      def ==(other)
        to_s == other.to_s
      end

      # Whether this schedule time is sortable.
      #
      # @return [Boolean]
      def sortable?
        !event
      end

      # Whether this schedule time falls within the given range of schedule
      # times.
      #
      # @param range [Range<AIXM::Schedule::Time>] range of schedule times
      # @return [Boolean]
      def in?(range)
        fail "not sortable" unless sortable? && range.first.sortable? && range.last.sortable?
        if range.min
          range.first.to_s <= self.to_s && self.to_s <= range.last.to_s
        else
          range.first.to_s <= self.to_s || self.to_s <= range.last.to_s
        end
      end

      private

      # Set the +@time+ instance variable.
      #
      # @param hour [Integer, String]
      # @param min [Integer, String]
      # @param offset [Integer, String] either UTC offset in seconds
      #   (default: 0) or 'UTC'
      # @return [Time]
      def set_time(hour, min, offset)
        @time = ::Time.new(DATELESS_DATE[0, 4], DATELESS_DATE[5, 2], DATELESS_DATE[8, 2], hour, min, 0, offset || 0).utc
      end

      def event=(value)
        fail ArgumentError if value && !EVENTS.include?(value)
        @event = value
      end

      def precedence=(value)
        fail ArgumentError if value && !PRECEDENCES.include?(value)
        @precedence = value
      end

      def <=>(other)
        to_time <=> other.to_time
      end
    end

  end
end
