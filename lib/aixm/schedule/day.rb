module AIXM
  module Schedule

    # Days suitable for schedules
    #
    # @example
    #   from = AIXM.day(:monday)           # => :monday
    #   to = AIXM.day(:thursday)           # => :thursday
    #   AIXM.day(:tuesday).in?(from..to)   # => true
    class Day
      include Comparable

      DAYS = %i(monday tuesday wednesday thursday friday saturday sunday workday day_preceding_workday day_following_workday holiday day_preceding_holiday day_following_holiday any).freeze
      SORTABLE_DAYS = DAYS[0, 7]

      # Day of the week or special named day
      #
      # @return [Symbol] any from {DAYS}
      attr_reader :day

      # Set the given day of the week or special named day.
      #
      # @param day [Symbol] any from {DAYS}
      def initialize(day=:any)
        self.day = day
      end

      # Human readable rap such as "monday" or "day preceding workday"
      #
      # @return [String]
      def to_s
        day.to_s.gsub('_', ' ')
      end

      def inspect
        %Q(#<#{self.class} #{to_s}>)
      end

      # Whether two days are equal.
      #
      # @return [Boolean]
      def ==(other)
        day == other.day
      end

      # Whether this schedule day sortable.
      #
      # @return [Boolean]
      def sortable?
        SORTABLE_DAYS.include? day
      end

      # Whether this schedule day falls within the given range of schedule
      # days.
      #
      # @note Only weekdays are sortable, therefore, this method returns +nil+
      #   if either self or the range contain a non-weekday.
      #
      # @param range [Range<AIXM::Schedule::Day>] range of schedule days
      # @raise RuntimeError if either self is or the range includes an
      #   unsortable non-workday
      # @return [Boolean]
      def in?(range)
        fail "includes unsortables" unless sortable? && range.first.sortable? && range.last.sortable?
        if range.min
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

      # @note Necessary to use this class in Range.
      def <=>(other)
        DAYS.index(day) <=> DAYS.index(other.day) || day.to_s <=> other.to_s
      end
    end

  end
end
