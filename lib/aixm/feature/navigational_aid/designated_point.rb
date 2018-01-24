module AIXM
  module Feature
    module NavigationalAid

      ##
      # Designated points are  named map coordinates
      #
      # Types:
      # * +:icao+ (+:ICAO+) - ICAO 5 letter name code designator
      # * +:adhp+ (+:ADHP+) - aerodrome/heliport related name code designator
      # * +:coordinates+ (+:COORD+) - point with identifier derived from its
      #                               geographical coordinates
      # * +:other+ (+:OTHER+) - other type
      class DesignatedPoint < Base
        using AIXM::Refinements

        TYPES = {
          ICAO: :icao,
          ADHP: :adhp,
          COORD: :coordinates,
          OTHER: :other
        }.freeze

        attr_reader :type

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, type:)
          super(id: id, name: name, xy: xy, z: z)
          @type = TYPES.lookup(type&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        ##
        # Digest to identify the payload
        def to_digest
          [super, type].to_digest
        end

        ##
        # Render AIXM
        def to_xml(*extensions)
          builder = to_builder(*extensions)
          builder.Dpn do |dpn|
            dpn.DpnUid({ newEntity: (true if extensions >> :ofm) }.compact) do |dpnuid|
              dpnuid.codeId(id)
              dpnuid.geoLat(xy.lat(format_for(*extensions)))
              dpnuid.geoLong(xy.long(format_for(*extensions)))
            end
            dpn.OrgUid
            dpn.txtName(name)
            dpn.codeDatum('WGE')
            dpn.codeType(type_key.to_s)
            if z
              dpn.valElev(z.alt)
              dpn.uomDistVer(z.unit.to_s)
            end
            dpn.txtRmk(remarks) if remarks
            dpn.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end

        def type_key
          TYPES.key(type)
        end
      end

    end
  end
end
