module AIXM
  module Feature
    module NavigationalAid

      ##
      # DME (distance measuring equipment) operate in the frequency band
      # between 962 MHz and 1213 MHz.
      #
      # https://en.wikipedia.org/wiki/Distance_measuring_equipment
      class DME < Base
        using AIXM::Refinements

        attr_reader :channel

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, channel:)
          super(id: id, name: name, xy: xy, z: z)
          @channel = channel&.upcase
        end

        ##
        # Digest to identify the payload
        def to_digest
          [super, channel].to_digest
        end

        ##
        # Render AIXM
        def to_xml(*extensions)
          builder = to_builder(*extensions)
          builder.Dme do |dme|
            dme.DmeUid({ newEntity: (true if extensions >> :ofm) }.compact) do |dmeuid|
              dmeuid.codeId(id)
              dmeuid.geoLat(xy.lat(@format))
              dmeuid.geoLong(xy.long(@format))
            end
            dme.OrgUid
            dme.txtName(name)
            dme.codeChannel(channel)
            dme.codeDatum('WGE')
            if z
              dme.valElev(z.alt)
              dme.uomDistVer(z.unit.to_s)
            end
            dme.txtRmk(remarks) if remarks
            dme.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end
      end

    end
  end
end
