using AIXM::Refinements

module AIXM
  class Component

    # FATO (final approach and take-off area) for vertical take-off aircraft
    # such as helicopters.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   fato = AIXM.fato(
    #     name: String
    #   )
    #   fato.length = AIXM.d or nil   # must use same unit as width
    #   fato.width = AIXM.d or nil    # must use same unit as length
    #   fato.surface = AIXM.surface
    #   fato.marking = String or nil
    #   fato.profile = String or nil
    #   fato.status = STATUSES or nil
    #   fato.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airport#fto-fato
    class FATO
      STATUSES = {
        CLSD: :closed,
        WIP: :work_in_progress,          # e.g. construction work
        PARKED: :parked_aircraft,        # parked or disabled aircraft on FATO
        FAILAID: :visual_aids_failure,   # failure or irregular operation of visual aids
        SPOWER: :secondary_power,        # secondary power supply in operation
        OTHER: :other                    # specify in remarks
      }.freeze

      # @return [AIXM::Feature::Airport] airport this FATO belongs to
      attr_reader :airport

      # @return [String] full name (e.g. "H1")
      attr_reader :name

      # @return [AIXM::D, nil] length
      attr_reader :length

      # @return [AIXM::D, nil] width
      attr_reader :width

      # @return [AIXM::Component::Surface] surface of the FATO
      attr_reader :surface

      # @return [String, nil] markings
      attr_reader :marking

      # @return [String, nil] profile description
      attr_reader :profile

      # @return [Symbol, nil] status of the FATO (see {STATUSES}) or +nil+ for normal operation
      attr_reader :status

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(name:)
        self.name = name
        @surface = AIXM.surface
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} airport=#{airport&.id.inspect} name=#{name.inspect}>)
      end

      def airport=(value)
        fail(ArgumentError, "invalid airport") unless value.is_a? AIXM::Feature::Airport
        @airport = value
      end
      private :airport=

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.is_a? String
        @name = value.uptrans
      end

      def length=(value)
        @length = if value
          fail(ArgumentError, "invalid length") unless value.is_a?(AIXM::D) && value.dist > 0
          fail(ArgumentError, "invalid length unit") if width && width.unit != value.unit
          @length = value
        end
      end

      def width=(value)
        @width = if value
          fail(ArgumentError, "invalid width") unless value.is_a?(AIXM::D)  && value.dist > 0
          fail(ArgumentError, "invalid width unit") if length && length.unit != value.unit
          @width = value
        end
      end

      def marking=(value)
        @marking = value&.to_s
      end

      def profile=(value)
        @profile = value&.to_s
      end

      def status=(value)
        @status = value.nil? ? nil : (STATUSES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid status"))
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.FtoUid do |fto_uid|
          fto_uid << airport.to_uid.indent(2)
          fto_uid.txtDesig(name)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Fto do |fto|
          fto << to_uid.indent(2)
          fto.valLen(length.dist.trim) if length
          fto.valWid(width.dist.trim) if width
          fto.uomDim(length.unit.to_s.upcase) if length
          fto.uomDim(width.unit.to_s.upcase) if width && !length
          unless  (xml = surface.to_xml).empty?
            fto << xml.indent(2)
          end
          fto.txtProfile(profile) if profile
          fto.txtMarking(marking) if marking
          fto.codeSts(STATUSES.key(status).to_s) if status
          fto.txtRmk(remarks) if remarks
        end
      end
    end
  end
end
