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
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airspace#frontier
      class Border < Point
        include AIXM::Memoize

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

        # @return [String] UID markup
        def to_uid(as: :GbrUid)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.tag!(as) do |tag|
            tag.txtName(name.to_s)
          end
        end
        memoize :to_uid

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx << to_uid.indent(2)
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
