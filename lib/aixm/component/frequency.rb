using AIXM::Refinements

module AIXM
  class Component

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
    class Frequency < Component
      include AIXM::Association
      include AIXM::Concerns::Timetable
      include AIXM::Concerns::Remarks

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

      # Frequency for transmission (outgoing)
      #
      # @overload transmission_f
      #   @return [AIXM::F]
      # @overload transmission_f=(value)
      #   @param value [AIXM::F]
      attr_reader :transmission_f


      # Map from languages (ISO 639-1) to callsigns
      #
      # @example
      #   { en: "STRASBOURG CONTROL", fr: "STRASBOURG CONTROLE" }
      #
      # @overload callsigns
      #   @return [Hash]
      # @overload callsigns=(value)
      #   @param value [Hash]
      attr_reader :callsigns


      # Frequency for reception (incoming)
      #
      # @note One-way services such as ATIS should set this to +nil+ and simplex
      #   (aka: non-duplex) communication should set this to {#transmission_f}.
      #
      # @overload reception_f
      #   @return [AIXM::F, nil]
      # @overload reception_f=(value)
      #   @param value [AIXM::F, nil]
      attr_reader :reception_f

      # Type of frequency
      #
      # @overload type
      #   @return [Symbol, nil] any of {TYPES}
      # @overload type=(value)
      #   @param value [Symbol, nil] any of {TYPES}
      attr_reader :type

      # See the {cheat sheet}[AIXM::Component::Frequency] for examples on how to
      # create instances of this class.
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

      # @!visibility private
      def add_uid_to(builder)
        builder.FqyUid do |fqy_uid|
          service.add_uid_to(fqy_uid)
          fqy_uid.valFreqTrans(transmission_f.freq)
        end
      end

      # @!visibility private
      def add_to(builder)
        builder.Fqy do |fqy|
          add_uid_to(fqy)
          fqy.valFreqRec(reception_f.freq) if reception_f
          fqy.uomFreq(transmission_f.unit.upcase)
          timetable.add_to(fqy, as: :Ftt) if timetable
          fqy.txtRmk(remarks) if remarks
          callsigns.each do |language, callsign|
            fqy.Cdl do |cdl|
              cdl.txtCallSign(callsign)
              cdl.codeLang(language.upcase)
            end
          end
        end
      end
    end

  end
end
