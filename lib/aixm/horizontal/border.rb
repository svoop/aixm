module AIXM
  module Horizontal
    class Border < Point

      attr_reader :name, :mid

      ##
      # Defines a (border) transition +name+/+mid+ starting at +xy+
      def initialize(xy:, name:, mid: nil)
        super(xy: xy)
        @mid, @name = mid, name
      end

      def to_xml
        builder = Builder::XmlMarkup.new
        builder.Avx do |avx|
          avx.codeType('FNT')
          avx.geoLat(xy.lat(:AIXM))
          avx.geoLong(xy.long(:AIXM))
          avx.GbrUid({ mid: mid }.compact) do |gbruid|
            gbruid.txtName('foobar')
          end
        end
      end

    end
  end
end
