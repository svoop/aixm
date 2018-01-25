module AIXM
  module Feature
    module NavigationalAid

      ##
      # NDB (non-directional beacon) operate in the frequency band between
      # 190 kHz and 1750 kHz.
      #
      # https://en.wikipedia.org/wiki/Non-directional_beacon
      class NDB < Base
        using AIXM::Refinements

        attr_reader :f

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, f:)
          super(id: id, name: name, xy: xy, z: z)
          @f = f
          fail(ArgumentError, "invalid frequency") unless f.is_a?(F) && f.between?(190, 1750, :khz)
        end

        ##
        # Digest to identify the payload
        def to_digest
          [super, f.to_digest].to_digest
        end

        ##
        # Render AIXM
        def to_xml(*extensions)
          builder = to_builder(*extensions)
          builder.Ndb do |ndb|
            ndb.NdbUid({ newEntity: (true if extensions >> :ofm) }.compact) do |ndbuid|
              ndbuid.codeId(id)
              ndbuid.geoLat(xy.lat(format_for(*extensions)))
              ndbuid.geoLong(xy.long(format_for(*extensions)))
            end
            ndb.OrgUid
            ndb.txtName(name)
            ndb.valFreq(f.freq.trim)
            ndb.uomFreq(f.unit.upcase.to_s)
            ndb.codeDatum('WGE')
            if z
              ndb.valElev(z.alt)
              ndb.uomDistVer(z.unit.to_s)
            end
            if schedule
              ndb.Ntt do |ntt|
                ntt << schedule.to_xml(*extensions).indent(4)
              end
            end
            ndb.txtRmk(remarks) if remarks
            ndb.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end
      end

    end
  end
end
