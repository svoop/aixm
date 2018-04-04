using AIXM::Refinements

module AIXM
  module Feature
    module NavigationalAid

      ##
      # DME (distance measuring equipment) operate in the frequency band
      # between 962 MHz and 1213 MHz.
      # https://en.wikipedia.org/wiki/Distance_measuring_equipment
      #
      # Arguments:
      # * +channel+ - radio channel
      class DME < Base
        attr_reader :channel, :vor

        public_class_method :new

        def initialize(source: nil, region: nil, id:, name:, xy:, z: nil, channel:)
          super(source: source, region: region, id: id, name: name, xy: xy, z: z)
          self.channel = channel
        end

        ##
        # Radio channel (e.g. "3X")
        def channel=(value)
          fail(ArgumentError, "invalid channel") unless value.is_a? String
          @channel = value.upcase
        end

        def vor=(value)
          fail(ArgumentError, "invalid VOR") unless value.is_a? VOR
          @vor = value
        end
        private :vor=

        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.DmeUid({ region: (region if AIXM.ofmx?) }.compact) do |dme_uid|
            dme_uid.codeId(id)
            dme_uid.geoLat(xy.lat(AIXM.schema))
            dme_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        def to_xml
          builder = to_builder
          builder.Dme({ source: (source if AIXM.ofmx?) }.compact) do |dme|
            dme << to_uid.indent(2)
            dme.OrgUid
            dme << vor.to_uid.indent(2) if vor
            dme.txtName(name) if name
            dme.codeChannel(channel)
            dme.codeDatum('WGE')
            if z
              dme.valElev(z.alt)
              dme.uomDistVer(z.unit.to_s)
            end
            dme << schedule.to_xml(as: :Dtt).indent(2) if schedule
            dme.txtRmk(remarks) if remarks
            dme.target!
          end
        end
      end

    end
  end
end
