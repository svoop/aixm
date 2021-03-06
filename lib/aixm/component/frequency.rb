using AIXM::Refinements

module AIXM
  module Component

    # Voice frequencies used by a service.
    #
    # By default, {#reception_f} is set to the same value as {#transmission_f}
    # since most services rely on simplex (aka: non-duplex) two-way
    # communication. For services with one-way communication only such as ATIS,
    # the {#reception_f} has to be set to +nil+ explicitly!
    #
    # ===Cheat Sheet in Pseudo Code:
    #   frequency = AIXM.frequency(
    #     transmission_f: AIXM.f
    #     callsigns: Hash
    #   )
    #   frequency.reception_f = AIXM.f or nil
    #   frequency.type = TYPES or nil
    #   frequency.timetable = AIXM.timetable or nil
    #   frequency.remarks = String or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Organisation#fqy-frequency
    class Frequency
      include AIXM::Association
      include AIXM::Memoize

      TYPES = {
        STD: :standard,
        ALT: :alternative,
        EMRG: :emergency,
        GUARD: :guard,
        MIL: :military,
        CIV: :civilian,
        OTHER: :other   # specify in remarks
      }.freeze

      # @!method service
      #   @return [AIXM::Component::Service] service the frequency belongs to
      belongs_to :service

      # @return [AIXM::F] frequency for transmission (outgoing)
      attr_reader :transmission_f

      # @example
      #   { en: "STRASBOURG CONTROL", fr: "STRASBOURG CONTROLE" }
      #
      # @return [Hash] map from languages (ISO 639-1) to callsigns
      attr_reader :callsigns

      # @note One-way services such as ATIS should set this to +nil+ and simplex
      #  (aka: non-duplex) communication should set this to {#transmission_f}.
      # @return [AIXM::F, nil] frequency for reception (incoming)
      attr_reader :reception_f

      # @return [Symbol, nil] type of frequency (see {TYPES})
      attr_reader :type

      # @return [AIXM::Component::Timetable, nil] operating hours
      attr_reader :timetable

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(transmission_f:, callsigns:)
        self.transmission_f, self.callsigns = transmission_f, callsigns
        self.reception_f = transmission_f
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} transmission_f=#{transmission_f.inspect} callsigns=#{callsigns.inspect}>)
      end

      def transmission_f=(value)
        fail(ArgumentError, "invalid transmission_f") unless value.is_a?(AIXM::F) && value.voice?
        @transmission_f = value
      end

      def callsigns=(value)
        fail(ArgumentError, "invalid callsigns") unless value.is_a?(Hash)
        @callsigns = value.transform_keys { _1.to_sym.downcase }.transform_values { _1.to_s.uptrans }
      end

      def reception_f=(value)
        fail(ArgumentError, "invalid reception_f") unless value.nil? || value.is_a?(AIXM::F) && value.voice?
        @reception_f = value
      end

      def type=(value)
        @type = value.nil? ? nil : TYPES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def timetable=(value)
        fail(ArgumentError, "invalid timetable") unless value.nil? || value.is_a?(AIXM::Component::Timetable)
        @timetable = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.FqyUid do |fqy_uid|
          fqy_uid << service.to_uid.indent(2)
          fqy_uid.valFreqTrans(transmission_f.freq)
        end
      end
      memoize :to_uid

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Fqy do |fqy|
          fqy << to_uid.indent(2)
          fqy.valFreqRec(reception_f.freq) if reception_f
          fqy.uomFreq(transmission_f.unit.upcase.to_s)
          fqy << timetable.to_xml(as: :Ftt).indent(2) if timetable
          fqy.txtRmk(remarks) if remarks
          callsigns.each do |language, callsign|
            fqy.Cdl do |cdl|
              cdl.txtCallSign(callsign)
              cdl.codeLang(language.upcase.to_s)
            end
          end
          fqy.target!
        end
      end
    end

  end
end
