module AIXM
  module Horizontal
    class Border < Point

      attr_reader :mid, :name

      ##
      # Defines a (border) transition +mid+/+name+ starting at +xy+
      def initialize(xy:, mid:, name:)
        super(xy: xy)
        @mid, @name = mid, name
      end

      def to_xml
        builder = Builder::XmlMarkup.new
        builder.Avx do |avx|
          avx.codeType('FNT')
          avx.geoLat(xy.lat(:AIXM))
          avx.geoLong(xy.long(:AIXM))
          avx.GbrUid(mid: mid) do |gbruid|
            gbruid.txtName('foobar')
          end
        end
      end

    end
  end
end
