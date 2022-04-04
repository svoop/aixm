module AIXM
  module Schedule

  # Dates suitable for schedules
  #
  # This class implements the bare minimum of stdlib +Date+ and adds some
  # extensions:
  # * yearless dates
  # * {in?} to check whether (yearless) date falls within (yearless) date range
  #
  # @example
  #   date = AIXM.date('2022-04-20')        # => 2022-04-20
  #   from = AIXM.date('03-20')             # => XXXX-03-20
  #   date.in?(from..AIXM.date('05-20'))    # => true
    class Date
      include Comparable
      extend Forwardable

      YEARLESS_YEAR = -8888

      # Parse the given representation of (yearless) date.
      #
      # @param date [Date, String] either stdlib Date, "YYYY-MM-DD" or "MM-DD"
      #   (yearless date)
      def initialize(date)
        @date = case date.to_s
        when /\A\d{4}-\d{2}-\d{2}\z/
          ::Date.strptime(date.to_s)
        when /\A\d{2}-\d{2}\z/
          ::Date.strptime("#{YEARLESS_YEAR}-#{date}")
        else
          fail ArgumentError
        end
      rescue ::Date::Error
        raise ArgumentError
      end

      # Stdlib Date equivalent using the value of {YEARLESS_YEAR} to represent a
      # yearless date.
      #
      # @return [Date]
      def to_date
        @date
      end

      # Human readable rap such as "2002-05-19" or "XXXX-05-19".
      #
      # @param format [String] see {strftime}[https://www.rubydoc.info/stdlib/date/DateTime#strftime-instance_method]
      # @return [String]
      def to_s(format='%Y-%m-%d')
        @date.strftime(yearless? ? format.sub('%Y', 'XXXX') : format)
      end

      def inspect
        %Q(#<#{self.class} #{to_s}>)
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
      def_delegators :to_date, :month, :day

      # Whether this schedule date falls within the given range of schedule dates
      #
      # @note It is possible to compare dates and ranges which may or may not
      # have years.
      #
      # @param range [Range<AIXM::Schedule::Date>] range of schedule dates
      # @return [Boolean]
      def in?(range)
        if range.first.yearless?
          yearless? ? in_yearless?(range) : to_yearless.in?(range)
        else
          yearless? ? in_yearless?(range.first.to_yearless..range.last.to_yearless) : range.cover?(self)
        end
      end

      private

      def in_yearless?(range)
        range.min ? range.cover?(self) : range.first <= self || self <= range.last
      end
    end

  end
end
