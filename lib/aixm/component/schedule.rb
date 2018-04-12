using AIXM::Refinements

module AIXM
  class Component

    # Schedules define activity time windows.
    #
    # @note As of now, only predefined schedules (see {CODES}) are imlemented.
    #
    # ===Cheat Sheat in Pseudo Code:
    #   schedule = AIXM.schedule(
    #     code: String or Symbol
    #   )
    #   schedule.remarks = String or nil
    #
    # ===Shortcuts:
    # * +AIXM::H24+ - continuous, all day and all night
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Timetable#predefined-timetable
    class Schedule
      CODES = {
        H24: :continuous,           # all day and all night
        HJ: :sunrise_to_sunset,     # all day
        HN: :sunset_to_sunrise,     # all night
        HX: :unspecified,
        HO: :operational_request,   # on request only
        NOTAM: :notam,              # see NOTAM
        OTHER: :other               # specify in remarks
      }.freeze

      # @return [Symbol] schedule code (see {CODES})
      attr_reader :code

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(code:)
        self.code = code
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} code=#{code.inspect}>)
      end

      def code=(value)
        @code = CODES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid code")
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] AIXM or OFMX markup
      def to_xml(as: :Timetable)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag.codeWorkHr(CODES.key(code).to_s)
          tag.txtRmkWorkHr(remarks) if remarks
        end
      end
    end

  end
end
