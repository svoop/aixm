module AIXM
  module Feature
    module NavigationalAid

      ##
      # NDB (non-directional beacon) operate in the frequency band between
      # 190 kHz and 1750 kHz.
      #
      # Types:
      # * +:en_route+ (+:B+) - high powered NDB
      # * +:locator+ (+:L+) - locator (low powered NDB)
      # * +:marine+ (+:M+) - marine beacon
      #
      # https://en.wikipedia.org/wiki/Non-directional_beacon
      class NDB < Base
        using AIXM::Refinements

        TYPES = {
          B: :en_route,
          L: :locator,
          M: :marine
        }.freeze

        attr_reader :type, :f

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, type:, f:)
          super(id: id, name: name, xy: xy, z: z)
          self.type, self.f = type, f
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def type_key
          TYPES.key(type)
        end

        def f=(value)
          fail(ArgumentError, "invalid f") unless value.is_a?(F) && value.between?(190, 1750, :khz)
          @f = value
        end

        ##
        # Digest to identify the payload
        def to_digest
          [super, f.to_digest].to_digest
        end

        ##
        # Render UID markup
        def to_uid(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.NdbUid({ mid: to_digest, newEntity: (true if extensions >> :ofm) }.compact) do |ndbuid|
            ndbuid.codeId(id)
            ndbuid.geoLat(xy.lat(format_for(*extensions)))
            ndbuid.geoLong(xy.long(format_for(*extensions)))
          end
        end

        ##
        # Render AIXM markup
        def to_aixm(*extensions)
          builder = to_builder(*extensions)
          builder.Ndb do |ndb|
            ndb << to_uid(*extensions).indent(2)
            ndb.OrgUid
            ndb.txtName(name) if name
            ndb.valFreq(f.freq.trim)
            ndb.uomFreq(f.unit.upcase.to_s)
            ndb.codeClass(type_key.to_s)
            ndb.codeDatum('WGE')
            if z
              ndb.valElev(z.alt)
              ndb.uomDistVer(z.unit.to_s)
            end
            if schedule
              ndb.Ntt do |ntt|
                ntt << schedule.to_aixm(*extensions).indent(4)
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
