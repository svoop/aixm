using AIXM::Refinements

module AIXM
  class Component

    # Surface of a runway, helipad etc
    #
    # ===Cheat Sheet in Pseudo Code:
    #   surface = AIXM.surface
    #   surface.composition: COMPOSITIONS or nil
    #   surface.preparation: PREPARATIONS or nil
    #   surface.condition: CONDITIONS or nil
    #   surface.pcn = String or nil
    #   surface.siwl_weight = AIXM.w
    #   surface.siwl_tire_pressure = AIXM.p
    #   surface.auw_weight = AIXM.w
    #   surface.remarks = String or nil
    #
    # ===Constants:
    # * +AIXM::PCN_RE+ - regular expression to match PCN notations
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#rwy-runway
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#tla-helipad-tlof
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#fto-fato
    class Surface < Component
      include AIXM::Concerns::Remarks

      COMPOSITIONS = {
        ASPH: :asphalt,
        BITUM: :bitumen,        # dug up, bound and rolled ground
        CONC: :concrete,
        'CONC+ASPH': :concrete_and_asphalt,
        'CONC+GRS': :concrete_and_grass,
        GRADE: :graded_earth,   # graded or rolled earth possibly with some grass
        GRASS: :grass,          # lawn
        GRAVE: :gravel,         # small and midsize rounded stones
        MACADAM: :macadam,      # small rounded stones
        METAL: :metal,
        SAND: :sand,
        SNOW: :snow,
        WATER: :water,
        OTHER: :other           # specify in remarks
      }.freeze

      PREPARATIONS = {
        AFSC: :aggregate_friction_seal_coat,
        GROOVED: :grooved,      # cut or plastic grooved
        NATURAL: :natural,      # no treatment
        OILED: :oiled,
        PAVED: :paved,
        PFC: :porous_friction_course,
        RFSC: :rubberized_friction_seal_coat,
        ROLLED: :rolled,
        OTHER: :other
      }.freeze

      CONDITIONS = {
        GOOD: :good,
        FAIR: :fair,
        POOR: :poor,
        OTHER: :other
      }.freeze

      # @return [Symbol, nil] composition of the surface (see {COMPOSITIONS})
      attr_reader :composition

      # @return [Symbol, nil] preparation of the surface (see {PREPARATIONS})
      attr_reader :preparation

      # @return [Symbol, nil] condition of the surface (see {CONDITIONS})
      attr_reader :condition

      # @return [AIXM::W, nil] single isolated wheel load weight
      attr_reader :siwl_weight

      # @return [AIXM::P, nil] single isolated wheel load tire pressure
      attr_reader :siwl_tire_pressure

      # @return [AIXM::W, nil] all-up wheel weight
      attr_reader :auw_weight

      # See the {cheat sheet}[AIXM::Component::Surface] for examples on how to
      # create instances of this class.
      def initialize
        @pcn = {}
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} composition=#{composition.inspect} preparation=#{preparation.inspect} condition=#{condition.inspect} pcn=#{pcn.inspect}>)
      end

      def composition=(value)
        @composition = value.nil? ? nil : COMPOSITIONS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid composition")
      end

      def preparation=(value)
        @preparation = value.nil? ? nil : PREPARATIONS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid preparation")
      end

      def condition=(value)
        @condition = value.nil? ? nil : CONDITIONS.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid condition")
      end

      # @return [String, nil] pavement classification number (e.g. "59/F/A/W/T")
      def pcn
        @pcn.none? ? nil : @pcn.values.join("/".freeze)
      end

      def pcn=(value)
        return @pcn = {} if value.nil?
        fail(ArgumentError, "invalid PCN") unless match = value.to_s.upcase.match(PCN_RE)
        @pcn = match.named_captures.reject{ _1 == 'pcn' }
      end

      def siwl_weight=(value)
        fail(ArgumentError, "invalid siwl_weight") unless value.nil? || value.is_a?(AIXM::W)
        @siwl_weight = value
      end

      def siwl_tire_pressure=(value)
        fail(ArgumentError, "invalid siwl_tire_pressure") unless value.nil? || value.is_a?(AIXM::P)
        @siwl_tire_pressure = value
      end

      def auw_weight=(value)
        fail(ArgumentError, "invalid auw_weight") unless value.nil? || value.is_a?(AIXM::W)
        @auw_weight = value
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: true)
        builder.codeComposition(COMPOSITIONS.key(composition).to_s) if composition
        builder.codePreparation(PREPARATIONS.key(preparation).to_s) if preparation
        builder.codeCondSfc(CONDITIONS.key(condition).to_s) if condition
        if pcn
          builder.valPcnClass(@pcn['capacity'])
          builder.codePcnPavementType(@pcn['type'])
          builder.codePcnPavementSubgrade(@pcn['subgrade'])
          builder.codePcnMaxTirePressure(@pcn['tire_pressure'])
          builder.codePcnEvalMethod(@pcn['evaluation_method'])
        end
        builder.txtPcnNote(@remarks) if remarks
        if siwl_weight
          builder.valSiwlWeight(siwl_weight.wgt.trim)
          builder.uomSiwlWeight(siwl_weight.unit.to_s.upcase)
        end
        if siwl_tire_pressure
          builder.valSiwlTirePressure(siwl_tire_pressure.pres.trim)
          builder.uomSiwlTirePressure(siwl_tire_pressure.unit.to_s.upcase)
        end
        if auw_weight
          builder.valAuwWeight(auw_weight.wgt.trim)
          builder.uomAuwWeight(auw_weight.unit.to_s.upcase)
        end
        builder.target!
      end
    end
  end
end
