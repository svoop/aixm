using AIXM::Refinements

module AIXM
  class Feature
    class NavigationalAid

      # A non-directional radio beacon (NDB) is a radio transmitter at a known
      # location operating in the frequency band between 190 kHz and 1750 kHz.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   ndb = AIXM.ndb(
      #     source: String or nil
      #     region: String or nil
      #     organisation: AIXM.organisation
      #     id: String
      #     name: String
      #     xy: AIXM.xy
      #     z: AIXM.z or nil
      #     type: TYPES
      #     f: AIXM.f
      #   )
      #   ndb.timetable = AIXM.timetable or nil
      #   ndb.remarks = String or nil
      #   ndb.comment = Object or nil
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Navigational-aid#ndb-ndb
      class NDB < NavigationalAid
        public_class_method :new

        TYPES = {
          B: :en_route,
          L: :locator,
          M: :marine,
          OTHER: :other   # specify in remarks
        }.freeze

        # Type of NDB
        #
        # @overload type
        #   @return [Symbol, nil] any of {TYPES}
        # @overload type=(value)
        #   @param value [Symbol, nil] any of {TYPES}
        attr_reader :type

        # Radio frequency
        #
        # @overload f
        #   @return [AIXM::F]
        # @overload f=(value)
        #   @param value [AIXM::F]
        attr_reader :f

        # See the {cheat sheet}[AIXM::Feature::NavigationalAid::NDB] for examples
        # on how to create instances of this class.
        def initialize(type:, f:, **arguments)
          super(**arguments)
          self.type, self.f = type, f
        end

        def type=(value)
          @type = value.nil? ? nil : TYPES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def f=(value)
          fail(ArgumentError, "invalid f") unless value.is_a?(F) && value.between?(190, 1750, :khz)
          @f = value
        end

        # @!visibility private
        def add_uid_to(builder)
          builder.NdbUid({ region: (region if AIXM.ofmx?) }.compact) do |ndb_uid|
            ndb_uid.codeId(id)
            ndb_uid.geoLat(xy.lat(AIXM.schema))
            ndb_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        # @!visibility private
        def add_to(builder)
          super
          builder.Ndb({ source: (source if AIXM.ofmx?) }.compact) do |ndb|
            ndb.comment(indented_comment) if comment
            add_uid_to(ndb)
            organisation.add_uid_to(ndb)
            ndb.txtName(name) if name
            ndb.valFreq(f.freq.trim)
            ndb.uomFreq(f.unit.upcase)
            ndb.codeClass(type_key) if type
            ndb.codeDatum('WGE')
            if z
              ndb.valElev(z.alt)
              ndb.uomDistVer(z.unit.upcase)
            end
            timetable.add_to(ndb, as: :Ntt) if timetable
            ndb.txtRmk(remarks) if remarks
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
