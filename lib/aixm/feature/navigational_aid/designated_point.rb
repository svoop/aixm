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
        private :organisation=
        private :organisation

        def initialize(type:, **arguments)
          super(organisation: false, z: nil, **arguments)
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
          builder.DpnUid({ region: (region if AIXM.ofmx?) }.compact) do |dpn_uid|
            dpn_uid.codeId(id)
            dpn_uid.geoLat(xy.lat(AIXM.schema))
            dpn_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        def to_xml
          builder = to_builder
          builder.Dpn({ source: (source if AIXM.ofmx?) }.compact) do |dpn|
            dpn << to_uid.indent(2)
            dpn.codeDatum('WGE')
            dpn.codeType(type_key.to_s)
            dpn.txtName(name) if name
            dpn.txtRmk(remarks) if remarks
            dpn.target!
          end
        end
      end

    end
  end
end
