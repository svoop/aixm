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

        # Name of the border
        #
        # @overload name
        #   @return [String]
        # @overload name=(value)
        #   @param value [String]
        attr_reader :name

        # See the {cheat sheet}[AIXM::Component::Geometry::Border] for examples
        # on how to create instances of this class.
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

        # @!visibility private
        def add_uid_to(builder, as: :GbrUid)
          builder.send(as) do |tag|
            tag.txtName(name.to_s)
          end
        end

        # @!visibility private
        def add_to(builder)
          builder.Avx do |avx|
            add_uid_to(avx)
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
