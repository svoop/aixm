using AIXM::Refinements

module AIXM
  module Schedule

    # Datetimes suitable for schedules
    #
    # This class combines +AIXM::Schedule::Date+ and +AIXM::Schedule::Time+:
    #
    # @example
    #   datetime = AIXM.datetime('2022-04-20', '20:00')   # => 2022-04-20 20:00
    #   datetime.date         # => 2022-04-20
    #   datetime.date.class   # => AIXM::Schedule::Date
    #   datetime.time         # => 20:00
    #   datetime.time.class   # => AIXM::Schedule::Time
    class DateTime

      # Date part
      #
      # @return [AIXM::Schedule::Date]
      attr_reader :date

      # Time part
      #
      # @return [AIXM::Schedule::Time]
      attr_reader :time

      # Parse the given representation of date and time.
      #
      # @param date [AIXM::Schedule::Date]
      # @param time [AIXM::Schedule::Time]
      def initialize(date, time)
        fail(ArgumentError, 'invalid date') unless date.instance_of? AIXM::Schedule::Date
        fail(ArgumentError, 'invalid time') unless time.instance_of? AIXM::Schedule::Time
        @date, @time = date, time
      end

      # Human readable representation such as "2002-05-19 20:00"
      #
      # @return [String]
      def to_s
        [@date.to_s, @time.to_s].join(' ')
      end

      def inspect
        %Q(#<#{self.class} #{to_s}>)
      end

      # @see Object#hash
      def hash
         [@date.hash, @time.hash].hash
      end
    end

  end
end
