module AIXM
  module Component

    ##
    # Schedules define activity time windows. As of now, only predefined
    # schedules are imlemented either by use of explicit (e.g. +:continuous+)
    # or short codes (e.g. +:H24+) as listed by the +CODES+ constant.
    #
    # Shortcuts:
    # * +AIXM::H24+ - continuous 24/7
    class Schedule < Base
      using AIXM::Refinements

      CODES = {
        continuous: :H24,
        sunrise_to_sunset: :HJ,
        sunset_to_sunrise: :HN,
        unspecified: :HX,
        operational_request: :HO,
        notam: :NOTAM
      }.freeze

      attr_reader :code

      def initialize(code:)
        @code = code&.to_sym
        @code = CODES[code] unless CODES.has_value? code
        fail(ArgumentError, "code `#{code}' not recognized") unless @code
      end

      ##
      # Digest to identify the payload
      def to_digest
        [code].to_digest
      end

      ##
      # Render AIXM
      def to_xml(*extensions)
        Builder::XmlMarkup.new(indent: 2).codeWorkHr(code.to_s)
      end
    end

  end
end
