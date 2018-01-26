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

        attr_reader :channel, :vor

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, channel:)
          super(id: id, name: name, xy: xy, z: z)
          self.channel = channel
        end

        def channel=(value)
          fail(ArgumentError, "invalid channel") unless value.is_a? String
          @channel = value.upcase
        end

        def vor=(value)
          fail(ArgumentError, "invalid VOR") unless value.is_a? VOR
          @vor = value
        end

        ##
        # Digest to identify the payload
        def to_digest
          [super, channel].to_digest
        end

        ##
        # Render UID markup
        def to_uid(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.DmeUid({ newEntity: (true if extensions >> :ofm) }.compact) do |dmeuid|
            dmeuid.codeId(id)
            dmeuid.geoLat(xy.lat(format_for(*extensions)))
            dmeuid.geoLong(xy.long(format_for(*extensions)))
          end
        end

        ##
        # Render AIXM markup
        def to_aixm(*extensions)
          builder = to_builder(*extensions)
          builder.Dme do |dme|
            dme << to_uid(*extensions).indent(2)
            dme.OrgUid
            dme << vor.to_uid(*extensions).indent(2) if vor
            dme.txtName(name)
            dme.codeChannel(channel)
            dme.codeDatum('WGE')
            if z
              dme.valElev(z.alt)
              dme.uomDistVer(z.unit.to_s)
            end
            if schedule
              dme.Dtt do |dtt|
                dtt << schedule.to_aixm(*extensions).indent(4)
              end
            end
            dme.txtRmk(remarks) if remarks
            dme.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end
      end

    end
  end
end
