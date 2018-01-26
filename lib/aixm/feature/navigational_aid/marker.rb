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

        # TODO: Marker require an associated ILS
#        def initialize(*args)
#          fail(NotImplementedError, "Marker are not fully implemented yet")
#        end

        ##
        # Render UID markup
        def to_uid(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.MkrUid({ newEntity: (true if extensions >> :ofm) }.compact) do |mkruid|
            mkruid.codeId(id)
            mkruid.geoLat(xy.lat(format_for(*extensions)))
            mkruid.geoLong(xy.long(format_for(*extensions)))
          end
        end

        ##
        # Render AIXM markup
        def to_xml(*extensions)
          builder = to_builder(*extensions)
          builder.Mkr do |mkr|
            mkr << to_uid(*extensions).indent(2)
            mkr.OrgUid
            mkr.valFreq(75)
            mkr.uomFreq('MHZ')
            mkr.txtName(name)
            mkr.codeDatum('WGE')
            if z
              mkr.valElev(z.alt)
              mkr.uomDistVer(z.unit.to_s)
            end
            if schedule
              mkr.Mtt do |mtt|
                mtt << schedule.to_xml(*extensions).indent(4)
              end
            end
            mkr.txtRmk(remarks) if remarks
            mkr.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end
      end

    end
  end
end
