module AIXM
  module Feature
    module NavigationalAid

      ##
      # Marker (marker beacons) operate on 75 MHz.
      #
      # https://en.wikipedia.org/wiki/Marker_beacon
      class Marker < Base
        using AIXM::Refinements

        public_class_method :new

        ##
        # Render AIXM
        def to_xml(*extensions)
          builder = to_builder(*extensions)
          builder.Mkr do |mkr|
            mkr.MkrUid({ newEntity: (true if extensions >> :ofm) }.compact) do |mkruid|
              mkruid.codeId(id)
              mkruid.geoLat(xy.lat(@format))
              mkruid.geoLong(xy.long(@format))
            end
            mkr.OrgUid
            mkr.valFreq(75)
            mkr.uomFreq('MHZ')
            mkr.txtName(name)
            mkr.codeDatum('WGE')
            if z
              mkr.valElev(z.alt)
              mkr.uomDistVer(z.unit.to_s)
            end
            mkr.txtRmk(remarks) if remarks
            mkr.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end
      end

    end
  end
end
