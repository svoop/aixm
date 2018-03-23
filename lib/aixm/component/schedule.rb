using AIXM::Refinements

module AIXM
  module Component

    ##
    # Schedules define activity time windows. As of now, only predefined
    # schedules are imlemented either by use of explicit (e.g. +:continuous+)
    # or short codes (e.g. +:H24+) as listed by the +CODES+ constant.
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
        NOTAM: :notam
      }.freeze

      attr_reader :code

      def initialize(code:)
        @code = CODES.lookup(code&.to_sym, nil) || fail(ArgumentError, "invalid code")
      end

      def to_xml
        Builder::XmlMarkup.new(indent: 2).codeWorkHr(CODES.key(code).to_s)
      end
    end

  end
end
