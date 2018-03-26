using AIXM::Refinements

module AIXM
  module Feature
    module NavigationalAid

      ##
      # Designated points are named map coordinates
      #
      # Arguments:
      # * +type+ - type of designated point
      class DesignatedPoint < Base
        TYPES = {
          ICAO: :icao,
          ADHP: :adhp,
          COORD: :coordinates,
          OTHER: :other
        }.freeze

        attr_reader :type

        public_class_method :new

        def initialize(id:, name: nil, xy:, z: nil, type:)
          super(id: id, name: name, xy: xy, z: z)
          self.type = type
        end

        ##
        # Type of designated point
        #
        # Allowed values:
        # * +:icao+ (+:ICAO+) - ICAO 5 letter name code designator
        # * +:adhp+ (+:ADHP+) - aerodrome/heliport related name code designator
        # * +:coordinates+ (+:COORD+) - point with identifier derived from its
        #                               geographical coordinates
        # * +:other+ (+:OTHER+) - specify in +remarks+
        def type=(value)
          @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def type_key
          TYPES.key(type)
        end

        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.DpnUid do |dpnuid|
            dpnuid.codeId(id)
            dpnuid.geoLat(xy.lat(AIXM.format))
            dpnuid.geoLong(xy.long(AIXM.format))
          end
        end

        def to_xml
          builder = to_builder
          builder.Dpn do |dpn|
            dpn << to_uid.indent(2)
            dpn.OrgUid
            dpn.txtName(name) if name
            dpn.codeDatum('WGE')
            dpn.codeType(type_key.to_s)
            if z
              dpn.valElev(z.alt)
              dpn.uomDistVer(z.unit.to_s)
            end
            dpn.txtRmk(remarks) if remarks
            dpn.target!
          end
        end
      end

    end
  end
end
