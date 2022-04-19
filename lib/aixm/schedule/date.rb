using AIXM::Refinements

module AIXM
  module Schedule

    # Dates suitable for schedules
    #
    # This class implements the bare minimum of stdlib +Date+ and adds some
    # extensions:
    #
    # * yearless dates
    # * {covered_by?} to check whether (yearless) date falls within (yearless)
    #   date range
    #
    # @example
    #   date = AIXM.date('2022-04-20')               # => 2022-04-20
    #   from = AIXM.date('03-20')                    # => XXXX-03-20
    #   date.covered_by?(from..AIXM.date('05-20'))   # => true
    class Date
      include AIXM::Concerns::HashEquality
      include Comparable
      extend Forwardable

      YEARLESS_YEAR = 0

      # @api private
      attr_accessor :date

      # Parse the given representation of (yearless) date.
      #
      # @param date [Date, String] either stdlib Date, "YYYY-MM-DD", "XXXX-MM-DD"
      #   or "MM-DD"
      #   (yearless date)
      def initialize(date)
        @date = case date.to_s
        when /\A\d{4}-\d{2}-\d{2}\z/
          ::Date.strptime(date.to_s)
        when /\A(?:XXXX-)?(\d{2}-\d{2})\z/
          ::Date.strptime("#{YEARLESS_YEAR}-#{$1}")
        else
          fail ArgumentError
        end
      rescue ::Date::Error
        raise ArgumentError
      end

      # Human readable representation such as "2002-05-19" or "XXXX-05-19"
      #
      # All formats from {strftime}[https://www.rubydoc.info/stdlib/date/Date#strftime-instance_method]
      # are supported, however, +%Y+ is replaced with "XXXX" for yearless dates.
      # Any other formats containing the year won't do so and should be avoided!
      #
      # @param format [String] see {strftime}[https://www.rubydoc.info/stdlib/date/Date#strftime-instance_method]
      # @return [String]
      def to_s(format='%Y-%m-%d')
        @date.strftime(yearless? ? format.gsub('%Y', 'XXXX') : format)
      end

      def inspect
        %Q(#<#{self.class} #{to_s}>)
      end

      # Creates a new date with the given parts altered.
      #
      # @example
      #   date = AIXM.date('2000-12-22')
      #   date.at(month: 4)               # => 2000-04-22
      #   date.at(year: 2020, day: 5)     # => 2020-12-05
      #   date.at(month: 1)               # => 2020-01-22
      #   date.at(month: 1, wrap: true)   # => 2021-01-22 (year incremented)
      #
      # @param year [Integer] new year
      # @param month [Integer] new month
      # @param day [Integer] new day
      # @param wrap [Boolean] whether to increment month when crossing month
      #   boundary and year when crossing year boundary
      # @return [AIXM::Schedule::Date]
      def at(year: nil, month: nil, day: nil, wrap: false)
        return self unless year || month || day
        wrap_month, wrap_year = day&.<(date.day), month&.<(date.month)
        date = ::Date.new(year || self.year || YEARLESS_YEAR, month || self.month, day || self.day)
        date = date.next_month if wrap && wrap_month && !month
        date = date.next_year if wrap && wrap_year && !year
        self.class.new(date.strftime(yearless? ? '%m-%d' : '%F'))
      end

      # Create new date one day after this one.
      #
      # @return [AIXM::Schedule::Date]
      def succ
        self.class.new(date.next_day).at(year: (YEARLESS_YEAR if yearless?))
      end

      # Convert date to day
      #
      # @raise [RuntimeError] if date is yearless
      # @return [AIXM::Schedule::Day]
      def to_day
        fail "cannot convert yearless date" if yearless?
        AIXM.day(date.wday)
      end

      # Stdlib Date equivalent using the value of {YEARLESS_YEAR} to represent a
      # yearless date.
      #
      # @return [Date]
      def to_date
        @date
      end

      # Whether the other schedule date can be compared to this one.
      #
      # @param other [AIXM::Schedule::Date]
      # @return [Boolean]
      def comparable_to?(other)
        other.instance_of?(self.class) && yearless? == other.yearless?
      end

      def <=>(other)
        fail "not comparable" unless comparable_to? other
        @date.jd <=> other.to_date.jd
      end

      # @see Object#hash
      def hash
         [self.class, @date.jd].hash
      end

      # Whether this schedule date is yearless or not.
      #
      # @return [Boolean]
      def yearless?
        @date.year == YEARLESS_YEAR
      end

      # Yearless duplicate of self
      #
      # @return [AIXM::Schedule::Date]
      def to_yearless
        yearless? ? self : self.class.new(to_s[5..])
      end

      # @return [Integer] year or +nil+ if yearless
      def year
        @date.year unless yearless?
      end

      # @!method month
      #   @return [Integer]
      # @!method day
      #   @return [Integer] day of month
      def_delegators :@date, :month, :day

      # Whether this schedule date falls within the given range of schedule dates
      #
      # @note It is possible to compare dates as well as days.
      #
      # @param other [AIXM::Schedule::Date, Range<AIXM::Schedule::Date>,
      #   AIXM::Schedule::Day, Range<AIXM::Schedule::Day>] single schedule
      #   date/day or range of schedule dates/days
      # @return [Boolean]
      def covered_by?(other)
        range = Range.from(other)
        case
        when range.first.instance_of?(AIXM::Schedule::Day)
          range.first.any? || to_day.covered_by?(range)
        when range.first.yearless?
          yearless? ? covered_by_yearless_date?(range) : to_yearless.covered_by?(range)
        else
          yearless? ? covered_by_yearless_date?(range.first.to_yearless..range.last.to_yearless) : range.cover?(self)
        end
      end

      private

      def covered_by_yearless_date?(range)
        range.min ? range.cover?(self) : range.first <= self || self <= range.last
      end
    end

  end
end
