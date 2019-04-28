using AIXM::Refinements

module AIXM
  class Component
    class Geometry

      # Borders are following natural or artifical border lines referenced by
      # {#name} and starting at {#xy}.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   border = AIXM.border(
      #     xy: AIXM.xy
      #     name: String
      #   )
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Airspace#frontier
      class Border < Point
        # @return [String] name of the border
        attr_reader :name

        def initialize(xy:, name:)
          super(xy: xy)
          self.name = name
        end

        # @return [String]
        def inspect
          %Q(#<#{self.class} xy="#{xy}" name=#{name.inspect}>)
        end

        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? String
          @name = value
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.GbrUid do |gbr_uid|
              gbr_uid.txtName(name.to_s)
            end
            avx.codeType('FNT')
            avx.geoLat(xy.lat(AIXM.schema))
            avx.geoLong(xy.long(AIXM.schema))
            avx.codeDatum('WGE')
          end
        end
      end

    end
  end
end
