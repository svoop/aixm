using AIXM::Refinements

module AIXM
  module Component

    ##
    # Schedules define activity time windows. As of now, only predefined
    # schedules are imlemented either by use of explicit (e.g. +:continuous+)
    # or short codes (e.g. +:H24+) as listed by the +CODES+ constant.
    #
    # Arguments:
    # * +code+ - predefined schedule code
    # * +remarks+ - free text remarks
    #
    # Codes:
    # * +:continuous+ (+:H24+) - all day and all night
    # * +:sunrise_to_sunset+ (+:HJ+) - all day
    # * +:sunset_to_sunrise+ (+:HN+) - all night
    # * +:unspecified+ (+:HX+) - schedule not specified
    # * +:operational_request+ (+:HO+) - on request
    # * +:notam+ (+:NOTAM+) - see notam
    # * +:other+ (+:OTHER+) - see remarks
    #
    # Shortcuts:
    # * +AIXM::H24+ - continuous 24/7
    class Schedule
      CODES = {
        H24: :continuous,
        HJ: :sunrise_to_sunset,
        HN: :sunset_to_sunrise,
        HX: :unspecified,
        HO: :operational_request,
        NOTAM: :notam,
        OTHER: :other
      }.freeze

      attr_reader :code, :remarks

      def initialize(code:)
        self.code = code
      end

      def code=(value)
        @code = CODES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid code")
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

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
