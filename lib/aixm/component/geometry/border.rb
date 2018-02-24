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
          @name = name
        end

        ##
        # Digest to identify the payload
        def to_digest
          [xy.lat, xy.long, name].to_digest
        end

        ##
        # Render XML
        def to_xml
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.Avx do |avx|
            avx.codeType('FNT')
            avx.geoLat(xy.lat(AIXM.format))
            avx.geoLong(xy.long(AIXM.format))
            avx.codeDatum('WGE')
            if AIXM.ofmx?
              avx.GbrUid do |gbruid|
                gbruid.txtName(name.to_s)
              end
            end
          end
        end
      end

    end
  end
end
