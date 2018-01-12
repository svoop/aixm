module AIXM
  module Horizontal
    class Border < Point

      using AIXM::Refinements

      attr_reader :name, :name_mid

      ##
      # Defines a (border) transition +name+/+mid+ starting at +xy+
      def initialize(xy:, name:, name_mid: nil)
        super(xy: xy)
        @name_mid, @name = name_mid, name
      end

      ##
      # Digest to identify the payload
      def to_digest
        [xy.lat, xy.long, name, name_mid].to_digest
      end

      def to_xml(*extensions)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Avx do |avx|
          avx.codeType('FNT')
          avx.geoLat(xy.lat(:AIXM))
          avx.geoLong(xy.long(:AIXM))
          avx.GbrUid({ mid: name_mid }.compact) do |gbruid|
            gbruid.txtName('foobar')
          end
        end
      end

    end
  end
end
