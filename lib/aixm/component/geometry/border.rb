using AIXM::Refinements

module AIXM
  module Component
    class Geometry

      ##
      # Borders are following natural or artifical border lines referenced by
      # +name+ and starting at +xy+.
      class Border < Point
        attr_reader :name

        def initialize(xy:, name:)
          super(xy: xy)
          self.name = name
        end

        def name=(value)
          fail(ArgumentError, "invalid name") unless value.is_a? String
          @name = value
        end

        def inspect
          %Q(#<#{self.class} xy="#{xy.to_s}">)
        end

        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.GbrUid do |gbr_uid|
              gbr_uid.txtName(name.to_s)
            end
            avx.codeType('FNT')
            avx.geoLat(xy.lat(AIXM.format))
            avx.geoLong(xy.long(AIXM.format))
            avx.codeDatum('WGE')
          end
        end
      end

    end
  end
end
