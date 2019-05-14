using AIXM::Refinements

module AIXM
  class Component

    # Surface of a runway, helipad etc
    #
    # ===Cheat Sheet in Pseudo Code:
    #   surface = AIXM.surfaceservice(
    #     composition: COMPOSITIONS or nil
    #     preparation: PREPARATIONS or nil
    #     condition: CONDITIONS or nil
    #   )
    #   surface.pcn = String or nil
    #   surface.remarks = String or nil
    #
    # ===Constants:
    # * +AIXM::PCN_RE+ - regular expression to match PCN notations
    #
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airport#rwy-runway
    class Surface
      COMPOSITIONS = {
        ASPH: :asphalt,
        BITUM: :bitumen,        # dug up, bound and rolled ground
        CONC: :concrete,
        GRADE: :graded_earth,   # graded or rolled earth possibly with some grass
        GRASS: :grass,          # lawn
        GRAVE: :gravel,         # small and midsize rounded stones
        MACADAM: :macadam,      # small rounded stones
        SAND: :sand,
        WATER: :water,
        OTHER: :other           # specify in remarks
      }

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
      }

      CONDITIONS = {
        GOOD: :good,
        FAIR: :fair,
        POOR: :poor,
        OTHER: :other
      }

      # @return [Symbol, nil] composition of the surface (see {COMPOSITIONS})
      attr_reader :composition

      # @return [Symbol, nil] preparation of the surface (see {PREPARATIONS})
      attr_reader :preparation

      # @return [Symbol, nil] condition of the surface (see {CONDITIONS})
      attr_reader :condition

      # @return [String, nil] free text remarks
      attr_reader :remarks

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
        @pcn.none? ? nil : @pcn.values.join("/")
      end

      def pcn=(value)
        return @pcn = {} if value.nil?
        fail(ArgumentError, "invalid PCN") unless match = value.to_s.upcase.match(PCN_RE)
        @pcn = match.named_captures.reject{ |k| k == 'pcn' }
      end

      def remarks=(value)
        @remarks = value&.to_s
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
        builder.target!
      end
    end
  end
end
