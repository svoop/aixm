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
      class DesignatedPoint < Base
        using AIXM::Refinements

        TYPES = {
          ICAO: :icao,
          ADHP: :adhp,
          COORD: :coordinates
        }.freeze

        attr_reader :type

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, type:)
          super(id: id, name: name, xy: xy, z: z)
          self.type = type
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def type_key
          TYPES.key(type)
        end

        ##
        # Digest to identify the payload
        def to_digest
          [super, type].to_digest
        end

        ##
        # Render UID markup
        def to_uid(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.DpnUid({ newEntity: (true if extensions >> :ofm) }.compact) do |dpnuid|
            dpnuid.codeId(id)
            dpnuid.geoLat(xy.lat(format_for(*extensions)))
            dpnuid.geoLong(xy.long(format_for(*extensions)))
          end
        end

        ##
        # Render AIXM markup
        def to_xml(*extensions)
          builder = to_builder(*extensions)
          builder.Dpn do |dpn|
            dpn << to_uid(*extensions).indent(2)
            dpn.OrgUid
            dpn.txtName(name)
            dpn.codeDatum('WGE')
            dpn.codeType(type_key.to_s)
            if z
              dpn.valElev(z.alt)
              dpn.uomDistVer(z.unit.to_s)
            end
            if schedule
              dpn.Dtt do |dtt|
                dtt << schedule.to_xml(*extensions).indent(4)
              end
            end
            dpn.txtRmk(remarks) if remarks
            dpn.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end
      end

    end
  end
end
