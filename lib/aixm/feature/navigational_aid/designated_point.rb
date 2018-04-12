using AIXM::Refinements

module AIXM
  class Feature
    class NavigationalAid

      # Named geographical location used in defining an ATS route, aircraft
      # flight paths or for other navigation purposes.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   designated_point = AIXM.designated_point(
      #     source: String or nil
      #     region: String or nil (falls back to AIXM.config.region)
      #     id: String
      #     name: String or nil
      #     xy: AIXM.xy
      #     type: TYPES
      #   )
      #   designated_point.remarks = String or nil
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Navigational-aid#dpn-designated-point
      class DesignatedPoint < NavigationalAid
        public_class_method :new
        private :organisation=
        private :organisation

        TYPES = {
          ICAO: :icao,           # five-letter ICAO name
          ADHP: :adhp,           # airport related name
          COORD: :coordinates,   # derived from geographical coordinates
          OTHER: :other          # specify in remarks
        }.freeze

        # @return [Symbol] type of designated point
        attr_reader :type

        def initialize(type:, **arguments)
          super(organisation: false, z: nil, **arguments)
          self.type = type
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.DpnUid({ region: (region if AIXM.ofmx?) }.compact) do |dpn_uid|
            dpn_uid.codeId(id)
            dpn_uid.geoLat(xy.lat(AIXM.schema))
            dpn_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        # @return [String] AIXM or OFMX markup
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

        private

        def type_key
          TYPES.key(type)
        end

      end

    end
  end
end
