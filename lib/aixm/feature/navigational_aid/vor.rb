module AIXM
  module Feature
    module NavigationalAid

      ##
      # VOR (VHF omnidirectional range) operate in the frequency band between
      # 108.00 Mhz to 117.95 MHz. Two type of VORs exist:
      #
      # Types:
      # * +:vor+ (+:VOR+) - standard VOR
      # * +:vordme+ (+:DVOR+) - VOR/DME
      #
      # North types:
      # * +:geographic+ (+:TRUE+) - VOR aligned towards geographic north
      # * +:grid+ (+:GRID+) - VOR aligned along north-south lines of the
      #                       universal transverse mercator grid imposed on
      #                       topographic maps by the USA and NATO
      # * +:magnetic+ (+:MAG+) - VOR aligned towards magnetic north
      # * +:other+ (+:OTHER+) - other north type
      #
      # https://en.wikipedia.org/wiki/VHF_omnidirectional_range
      class VOR < Base
        using AIXM::Refinements

        TYPES = {
          VOR: :vor,
          DVOR: :vordme
        }.freeze

        NORTHS = {
          TRUE: :geographic,
          GRID: :grid,
          MAG: :magnetic,
          OTHER: :other
        }.freeze

        attr_reader :type, :f, :north

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, type:, f:, north:)
          super(id: id, name: name, xy: xy, z: z)
          @type = TYPES.lookup(type&.to_sym, nil) || fail(ArgumentError, "invalid type")
          @north = NORTHS.lookup(north&.to_sym, nil) || fail(ArgumentError, "invalid north")
          @f = f
          fail(ArgumentError, "invalid frequency") unless f.is_a?(F) && f.between?(108, 117.95, :mhz)
        end

        ##
        # Digest to identify the payload
        def to_digest
          [super, type, f.to_digest, north].to_digest
        end

        ##
        # Render AIXM
        def to_xml(*extensions)
          builder = to_builder(*extensions)
          builder.Vor do |vor|
            vor.VorUid({ newEntity: (true if extensions >> :ofm) }.compact) do |voruid|
              voruid.codeId(id)
              voruid.geoLat(xy.lat(format_for(*extensions)))
              voruid.geoLong(xy.long(format_for(*extensions)))
            end
            vor.OrgUid
            vor.txtName(name)
            vor.codeType(type_key.to_s)
            vor.valFreq(f.freq.trim)
            vor.uomFreq(f.unit.upcase.to_s)
            vor.codeTypeNorth(north_key.to_s)
            vor.codeDatum('WGE')
            if z
              vor.valElev(z.alt)
              vor.uomDistVer(z.unit.to_s)
            end
            vor.txtRmk(remarks) if remarks
            vor.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end

        def type_key
          TYPES.key(type)
        end

        def north_key
          NORTHS.key(north)
        end
      end

    end
  end
end
