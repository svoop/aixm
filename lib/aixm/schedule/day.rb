using AIXM::Refinements

module AIXM
  module Schedule

    # Days suitable for schedules
    #
    # @example
    #   from = AIXM.day(:monday)                   # => :monday
    #   to = AIXM.day(4)                           # => :thursday
    #   AIXM.day(:tuesday).covered_by?(from..to)   # => true
    class Day
      include AIXM::Concerns::HashEquality
      include Comparable

      WEEKDAYS = %i(sunday monday tuesday wednesday thursday friday saturday).freeze
      DAYS =  (WEEKDAYS + %i(workday day_preceding_workday day_following_workday holiday day_preceding_holiday day_following_holiday any)).freeze

      # Day of the week or special named day
      #
      # @return [Symbol] any from {DAYS}
      attr_reader :day

      # Set the given day of the week or special named day.
      #
      # @param day [Symbol, String, Integer] any from {DAYS} or 0=Monday to
      #   6=Sunday
      def initialize(day=:any)
        case day
        when Symbol, String
          self.day = day
        when Integer
          fail ArgumentError unless day.between?(0, 6)
          self.day = WEEKDAYS[day]
        else
          fail ArgumentError
        end
      end

      # Human readable representation such as "monday" or "day preceding workday"
      #
      # @return [String]
      def to_s
        day.to_s.gsub('_', ' ')
      end

      # Symbol used to initialize this day
      #
      # @return [Symbol]
      def to_sym
        day.to_s.to_sym
      end

      def inspect
        %Q(#<#{self.class} #{to_s}>)
      end

      # Create new day one day prior to this one.
      #
      # @return [AIXM::Schedule::Day]
      def pred
        return self if any?
        fail(TypeError, "can't iterate from #{day}") unless wday
        self.class.new(WEEKDAYS[wday.pred % 7])
      end
      alias_method :prev, :pred

      # Create new day one day after this one.
      #
      # @return [AIXM::Schedule::Day]
      def succ
        return self if any?
        fail(TypeError, "can't iterate from #{day}") unless wday
        self.class.new(WEEKDAYS[wday.succ % 7])
      end
      alias_method :next, :succ

      # Whether two days are equal.
      #
      # @return [Boolean]
      def ==(other)
        day == other.day
      end

      # @see Object#hash
      def hash
        [self.class, day].hash
      end

      # Whether the day is set to :any
      #
      # @return [Boolean]
      def any?
        day == :any
      end

      # Whether this schedule day sortable.
      #
      # @return [Boolean]
      def sortable?
        WEEKDAYS.include? day
      end

      # Whether this schedule day falls within the given range of schedule
      # days.
      #
      # @note Only weekdays and +:any+ can be computed!
      #
      # @param other [AIXM::Schedule::Day, Range<AIXM::Schedule::Day>] single
      #   schedule day or range of schedule days
      # @raise RuntimeError if anything but workdays or +:any+ are involved
      # @return [Boolean]
      def covered_by?(other)
        range = Range.from other
        case
        when any? || range.first.any? || range.last.any?
          true
        when !sortable? || !range.first.sortable? || !range.last.sortable?
          fail "includes unsortables"
        when range.min
          range.cover? self
        else
          range.first <= self || self <= range.last
        end
      end

      private

      def day=(value)
        @day = value.to_s.to_sym
        fail ArgumentError unless DAYS.include? @day
      end

      def wday
        WEEKDAYS.index(day.to_sym)
      end

      # @note Necessary to use this class in Range.
      def <=>(other)
        DAYS.index(day) <=> DAYS.index(other.day) || day.to_s <=> other.to_s
      end
    end

  end
end
