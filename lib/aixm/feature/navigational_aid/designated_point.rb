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
      #     region: String or nil
      #     id: String
      #     name: String or nil
      #     xy: AIXM.xy
      #     type: TYPES
      #   )
      #   designated_point.airport = AIXM.airport or nil
      #   designated_point.remarks = String or nil
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Navigational-aid#dpn-designated-point
      class DesignatedPoint < NavigationalAid
        include AIXM::Association

        public_class_method :new

        TYPES = {
          ICAO: :icao,                                 # five-letter ICAO id
          ADHP: :adhp,                                 # airport related id
          COORD: :coordinates,                         # derived from geographical coordinates
          'VFR-RP': :vfr_reporting_point,              # usually one or two letter id
          'VFR-MRP': :vfr_mandatory_reporting_point,   # usually one or two letter id
          'VFR-ENR': :vfr_en_route_point,
          'VFR-GLD': :vfr_glider_point,
          OTHER: :other                                # specify in remarks
        }.freeze

        # @return [AIXM::Feature::Airport] airport this designated point is
        #   associated with
        belongs_to :airport

        # @return [Symbol] type of designated point
        attr_reader :type

        def initialize(type:, **arguments)
          super(organisation: nil, z: nil, **arguments)
          self.type = type
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          insert_mid(
            builder.DpnUid({ region: (region if AIXM.ofmx?) }.compact) do |dpn_uid|
              dpn_uid.codeId(id)
              dpn_uid.geoLat(xy.lat(AIXM.schema))
              dpn_uid.geoLong(xy.long(AIXM.schema))
            end
          )
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = to_builder
          builder.Dpn({ source: (source if AIXM.ofmx?) }.compact) do |dpn|
            dpn << to_uid.indent(2)
            dpn << airport.to_uid(as: :AhpUidAssoc).indent(2) if airport
            dpn.codeDatum('WGE')
            dpn.codeType(AIXM.aixm? && type_key =~ /^VFR/ ? 'OTHER' : type_key.to_s)
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
