using AIXM::Refinements

module AIXM
  module Schedule

    # Times suitable for schedules
    #
    # This class implements the bare minimum of stdlib +Time+ and adds some
    # extensions:
    #
    # * converts to UTC
    # * date, seconds and milliseconds are ignored
    # * {covered_by?} to check whether schedule time falls within range of times
    #
    # @note The {DATELESS_DATE} is used to mark the date of the internal +Time"
    #   object irrelevant. However, Ruby does not persist end of days as 24:00,
    #   therefore {DATELESS_DATE} + 1 marks this case.
    #
    # @example
    #   time = AIXM.time('21:30')                                  # => 21:30
    #   time.covered_by?(AIXM.time('20:00')..AIXM.time('02:00'))   # => true
    class Time
      include AIXM::Concerns::HashEquality
      extend Forwardable

      EVENTS = %i(sunrise sunset).freeze
      PRECEDENCES = { first: :min, last: :max }.freeze
      DATELESS_DATE = ::Date.parse('0000-01-01').freeze

      # @api private
      attr_accessor :time

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
      # @return [Symbol, nil] any key of {PRECEDENCES}
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
      # @param whichever_comes [Symbol] any key from {PRECEDENCES}
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

      # Human readable representation
      #
      # The format recognises does the following interpolations:
      # * +%R+ - "HH:MM" in UTC if time is present, "" otherwise
      # * +%z+ - "UTC" if time is present, "" otherwise
      # * +%o+ - "or" if both time and event are present, "" otherwise
      # * +%E+ - "sunrise-15min" if no event is present, "" otherwise
      # * +%P+ - "whichever comes first" if precedence is present, "" otherwise
      #
      # @param format [String]
      # @return [String]
      def to_s(format='%R %z %o %E %P')
        format.gsub(/%[RzoEP]/,
          '%R' => (sprintf("%02d:%02d", hour, min) if @time),
          '%z' => ('UTC' if @time),
          '%o' => ('or' if @time && event),
          '%E' => "#{event}#{sprintf("%+dmin", delta) unless delta.zero?}",
          '%P' => ("whichever comes #{precedence}" if precedence)
        ).compact
      end

      def inspect
        %Q(#<#{self.class} #{to_s}>)
      end

      # Creates a new time with the given parts altered.
      #
      # @example
      #   time = AIXM.time('22:12')
      #   time.at(min: 0)               # => 22:00
      #   time.at(min: 0 wrap: true)   # => 2021-01-22 (year incremented)
      #
      # @param hour [Integer] new hour
      # @param min [Integer] new minutes
      # @param wrap [Boolean] whether to increment hour when crossing minutes
      #   boundary
      # @return [AIXM::Schedule::Date]
      def at(hour: nil, min: nil, wrap: false)
        return self unless hour || min
        min ||= time.min
        hour ||= time.hour
        hour = (hour + 1) % 24 if wrap && min < time.min
        self.class.new("%02d:%02d" % [hour, min])
      end

      # Resolve event to simple time
      #
      # * If +self+ doesn't have any event, +self+ is returned.
      # * Otherwise a new time is created with the event resolved for the
      #   given date and geographical location.
      #
      # @example
      #   time = AIXM.time('21:00', or: :sunset, minus: 30, whichever_cones: first)
      #   time.resolve(on: AIXM.date('2000-08-01'), at: AIXM.xy(lat: 48.8584, long: 2.2945))
      #   # => 20:50
      #
      # @param on [AIXM::Date] defaults to today
      # @param xy [AIXM::XY]
      # @return [AIXM::Schedule::Time, self]
      def resolve(on:, xy:)
        if resolved?
          self
        else
          sun_time = self.class.new(Sun.send(event, on.to_date, xy.lat, xy.long).utc + (delta * 60))
          if time
            self.class.new([sun_time.time, self.time].send(PRECEDENCES.fetch(precedence)))
          else
            sun_time
          end
        end
      end

      # Whether this time is resolved and doesn't contain an event (anymore).
      #
      # @return [Boolean]
      def resolved?
        !event
      end

      # Stdlib Time equivalent using the value of {DATELESS_DATE} to represent a
      # time only.
      #
      # @return [Time]
      def to_time
        @time
      end

      # Hour from 0 (beginning of day) to 24 (end of day)
      #
      # @return [Integer]
      def hour
        @time.hour + (end_of_day? ? 24 : 0)
      end

      # @!method min
      #   @return [Integer]
      def_delegators :@time, :min

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
      # @param other [AIXM::Schedule::Time, Range<AIXM::Schedule::Time>] single
      #   schedule time or range of schedule times
      # @raise RuntimeError if either self is or the range contains an
      #   unsortable time with event
      # @return [Boolean]
      def covered_by?(other)
        range = Range.from(other)
        case
        when !sortable? || !range.first.sortable? || !range.last.sortable?
          fail "includes unsortables"
        when range.min
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
        @time = ::Time.new(DATELESS_DATE.year, DATELESS_DATE.month, DATELESS_DATE.day, hour, min, 0, offset || 0).utc
      end

      def event=(value)
        fail ArgumentError if value && !EVENTS.include?(value)
        @event = value
      end

      def precedence=(value)
        fail ArgumentError if value && !PRECEDENCES.has_key?(value)
        @precedence = value
      end

      def end_of_day?
        @time.day > DATELESS_DATE.day
      end

      # @note Necessary to use this class in Range.
      def <=>(other)
        to_time <=> other.to_time || to_s <=> other.to_s
      end
    end

  end
end
