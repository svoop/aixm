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
      #   designated_point.comment = Object or nil
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Navigational-aid#dpn-designated-point
      class DesignatedPoint < NavigationalAid
        include AIXM::Concerns::Association

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

        # Type of designated point
        #
        # @overload type
        #   @return [Symbol] any of {TYPES}
        # @overload type=(value)
        #   @param value [Symbol] any of {TYPES}
        attr_reader :type

        # See the {cheat sheet}[AIXM::Feature::NavigationalAid::DesignatedPoint]
        # for examples on how to create instances of this class.
        def initialize(type:, **arguments)
          super(organisation: nil, z: nil, **arguments)
          self.type = type
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        # @!visibility private
        def add_uid_to(builder)
          builder.DpnUid({ region: (region if AIXM.ofmx?) }.compact) do |dpn_uid|
            dpn_uid.codeId(id)
            dpn_uid.geoLat(xy.lat(AIXM.schema))
            dpn_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        # @!visibility private
        def add_to(builder)
          super
          builder.Dpn({ source: (source if AIXM.ofmx?) }.compact) do |dpn|
            dpn.comment(indented_comment) if comment
            add_uid_to(dpn)
            airport.add_uid_to(dpn, as: :AhpUidAssoc) if airport
            dpn.codeDatum('WGE')
            dpn.codeType(AIXM.aixm? && type_key =~ /^VFR/ ? 'OTHER' : type_key)
            dpn.txtName(name) if name
            dpn.txtRmk(remarks) if remarks
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
