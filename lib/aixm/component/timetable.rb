using AIXM::Refinements

module AIXM
  class Component

    # Timetables define activity time windows.
    #
    # ===Cheat Sheat in Pseudo Code:
    #   timetable = AIXM.timetable(
    #     code: String or Symbol (default: :timesheet)
    #   )
    #   timetable.add_timesheet(AIXM.timesheet)
    #   timetable.remarks = String or nil
    #
    # ===Shortcuts:
    # * +AIXM::H24+ - continuous, all day and all night
    # * +AIXM::H_RE+ - pattern matching working hour codes
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Timetable#predefined-timetable
    class Timetable < Component
      include AIXM::Association
      include AIXM::Concerns::Remarks

      CODES = {
        TIMSH: :timesheet,          # attached timesheet
        H24: :continuous,           # all day and all night
        HJ: :sunrise_to_sunset,     # all day
        HN: :sunset_to_sunrise,     # all night
        HX: :unspecified,
        HO: :operational_request,   # on request only
        NOTAM: :notam,              # see NOTAM
        OTHER: :other               # specify in remarks
      }.freeze

      # @!method timesheets
      #   @return [Array<AIXM::Component::Timesheet>] timesheets attached to
      #     this timetable
      #
      # @!method add_timesheet(timesheet)
      #   @note The {#code} is forced to +:timesheet+ once at least one timesheet
      #     has been added.
      #   @param timesheet [AIXM::Component::Timesheet]
      has_many :timesheets

      # See the {cheat sheet}[AIXM::Component::Timetable] for examples on how to
      # create instances of this class.
      def initialize(code: :timesheet)
        self.code = code
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} code=#{code.inspect}>)
      end

      # Timetable code
      #
      # @!attribute code
      # @overload code
      #   @return [Symbol] any of {CODES}
      # @overload code=(value)
      #   @param value [Symbol] any of {CODES}
      def code
        timesheets.any? ? :timesheet : @code
      end

      def code=(value)
        @code = if value
          CODES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid code")
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml(as: :Timetable)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag.codeWorkHr(CODES.key(code).to_s)
          timesheets.each do |timesheet|
           tag << timesheet.to_xml.indent(2)
          end
          tag.txtRmkWorkHr(remarks) if remarks
        end
      end
    end

  end
end
