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
        format = extensions.include?(:OFM) ? :OFM : :AIXM
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.Avx do |avx|
          avx.codeType('FNT')
          avx.geoLat(xy.lat(format))
          avx.geoLong(xy.long(format))
          avx.codeDatum('WGE')
          # TODO: Find examples how to do this with vanilla AIXM
          if extensions.include?(:OFM)
            avx.GbrUid do |gbruid|
              gbruid.txtName(name.to_s)
            end
          end
        end
      end

    end
  end
end
