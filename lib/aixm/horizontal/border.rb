module AIXM
  module Horizontal
    class Border < Point

      using AIXM::Refinements

      attr_reader :name

      ##
      # Defines a (border) transition +name+ starting at +xy+
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
      # Render AIXM
      #
      # Extensions:
      # * +:OFM+ - Open Flightmaps
      def to_xml(*extensions)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Avx do |avx|
          avx.codeType('FNT')
          avx.geoLat(xy.lat(:AIXM))
          avx.geoLong(xy.long(:AIXM))
          avx.codeDatum('WGE')
          # TODO: Find examples how to do this with vanilla AIXM
          if extensions.include?(:OFM)
            avx.GbrUid do |gbruid|
              gbruid.txtName(name)
            end
          end
        end
      end

    end
  end
end
