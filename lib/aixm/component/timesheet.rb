using AIXM::Refinements

module AIXM
  class Component

    # Timesheets define customized activity time windows.
    #
    # AIXM supports only yearless dates whereas OFMX extends the model to
    # accommodate years as well, therefore, the year part is ignored for AIXM.
    #
    # ===Cheat Sheat in Pseudo Code:
    #   timesheet = AIXM.timesheet(
    #     adjust_to_dst: Boolean
    #     dates: (AIXM.date..AIXM.date)
    #     days: (AIXM.day..AIXM..day)     # either: range of days
    #     day: AIXM.day (default: :any)   # or: single day
    #   )
    #   timesheet.times = (AIXM.time..AIXM_time)
    #
    # @see https://gitlab.com/openflightmaps/ofmx/-/wikis/Timetable#custom-timetable
    class Timesheet < Component

      DAYS = {
        MON: :monday,
        TUE: :tuesday,
        WED: :wednesday,
        THU: :thursday,
        FRI: :friday,
        SAT: :saturday,
        SUN: :sunday,
        WD: :workday,
        PWD: :day_preceding_workday,
        AWD: :day_following_workday,
        LH: :holiday,
        PLH: :day_preceding_holiday,
        ALH: :day_following_holiday,
        ANY: :any
      }

      EVENTS = {
        SR: :sunrise,
        SS: :sunset
      }

      PRECEDENCES = {
        E: :first,
        L: :last
      }

      # Range of schedule dates for which this timesheet is active.
      #
      # @note Neither open beginning nor open ending is allowed.
      #
      # @overload dates
      #   @return [Range<AIXM::Schedule::Date>]
      # @overload dates=(value)
      #   @param value [Range<AIXM::Schedule::Date>] range of schedule dates
      #     either all with year or all yearless
      attr_reader :dates

      # Day or days for which this timesheet is active.
      #
      # @note Neither open beginning nor open ending is allowed.
      #
      # @overload day
      #   @return [AIXM::Schedule::Day]
      # @overload days
      #   @return [Range<AIXM::Schedule::Day>]
      # @overload day=(value)
      #   @param value [AIXM::Schedule::Day] schedule day
      # @overload days=(value)
      #   @param value [Range<AIXM::Schedule::Day>] range of schedule days
      attr_reader :days

      # Range of schedule times for which this timesheet is active.
      #
      # @note Either open beginning or open ending is allowed.
      #
      # @overload times
      #   @return [Range<AIXM::Schedule::Time>, nil] range of schedule times
      # @overload times=(value)
      #   @param value [Range<AIXM::Schedule::Time>, nil] range of schedule times
      attr_reader :times

      # See the {cheat sheet}[AIXM::Component::Timesheet] for examples on how to
      # create instances of this class.
      def initialize(adjust_to_dst:, dates:, days: nil, day: AIXM::ANY_DAY)
        self.adjust_to_dst, self.dates = adjust_to_dst, dates
        if days
          self.days = days
        else
          self.day = day
        end
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} dates=#{dates.inspect}>)
      end

      # Whether to adjust to dayight savings time.
      #
      # @note See the {OFMX docs}[https://gitlab.com/openflightmaps/ofmx/-/wikis/Timetable#custom-timetable]
      #   for how exactly this affects dates and times.
      #
      # @!attribute adjust_to_dst
      # @overload adjust_to_dst?
      #   @return [Boolean]
      # @overload adjust_to_dst=(value)
      #   @param value [Boolean]
      def adjust_to_dst?
        @adjust_to_dst
      end

      def adjust_to_dst=(value)
        fail(ArgumentError, "invalid adjust_to_dst") unless [true, false].include? value
        @adjust_to_dst = value
      end

      def dates=(value)
        fail(ArgumentError, 'invalid dates') unless value.instance_of?(Range) && value.begin && value.end
        @dates = value
      end

      def days=(value)
        fail(ArgumentError, 'invalid days') unless value.instance_of?(Range) && value.begin && value.end
        @days = value
      end

      def times=(value)
        fail(ArgumentError, 'invalid times') unless value.nil? || (value.instance_of?(Range) && value.begin && value.end)
        @times = value
      end

      def day
        @days unless @days.instance_of? Range
      end

      def day=(value)
        fail(ArgumentError, 'invalid day') unless value.instance_of? AIXM::Schedule::Day
        @days = value
      end

      # @!visibility private
      def add_to(builder)
        builder.Timsh do |timsh|
          timsh.codeTimeRef(adjust_to_dst? ? 'UTCW' : 'UTC')
          timsh.dateValidWef(dates.begin.to_s('%d-%m'))
          timsh.dateYearValidWef(dates.begin.year) if AIXM.ofmx? && !dates.begin.yearless?
          timsh.dateValidTil(dates.end.to_s('%d-%m'))
          timsh.dateYearValidTil(dates.end.year) if AIXM.ofmx? && !dates.end.yearless?
          if days.instance_of? Range
            timsh.codeDay(DAYS.key(days.begin.day))
            timsh.codeDayTil(DAYS.key(days.end.day))
          else
            timsh.codeDay(DAYS.key(days.day))
          end
          if times
            if times.begin
              timsh.timeWef(times.begin.to_s('%R'))
              timsh.codeEventWef(EVENTS.key(times.begin.event)) if times.begin.event
              timsh.timeRelEventWef(times.begin.delta) unless times.begin.delta.zero?
              timsh.codeCombWef(PRECEDENCES.key(times.begin.precedence)) if times.begin.precedence
            end
            if times.end
              timsh.timeTil(times.end.to_s('%R'))
              timsh.codeEventTil(EVENTS.key(times.end.event)) if times.end.event
              timsh.timeRelEventTil(times.end.delta) unless times.end.delta.zero?
              timsh.codeCombTil(PRECEDENCES.key(times.end.precedence)) if times.end.precedence
            end
          end
        end
      end
    end

  end
end
