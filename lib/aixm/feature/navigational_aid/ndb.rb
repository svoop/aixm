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
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Navigational-aid#ndb-ndb
      class NDB < NavigationalAid
        public_class_method :new

        TYPES = {
          B: :en_route,
          L: :locator,
          M: :marine,
          OTHER: :other   # specify in remarks
        }.freeze

        # @return [Symbol, nil] type of NDB (see {TYPES})
        attr_reader :type

        # @return [AIXM::F] radio frequency
        attr_reader :f

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

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.NdbUid do |ndb_uid|
            ndb_uid.codeId(id)
            ndb_uid.geoLat(xy.lat(AIXM.schema))
            ndb_uid.geoLong(xy.long(AIXM.schema))
          end.insert_payload_hash(region: AIXM.config.mid_region)
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = to_builder
          builder.Ndb({ source: (source if AIXM.ofmx?) }.compact) do |ndb|
            ndb << to_uid.indent(2)
            ndb << organisation.to_uid.indent(2)
            ndb.txtName(name) if name
            ndb.valFreq(f.freq.trim)
            ndb.uomFreq(f.unit.upcase.to_s)
            ndb.codeClass(type_key.to_s) if type
            ndb.codeDatum('WGE')
            if z
              ndb.valElev(z.alt)
              ndb.uomDistVer(z.unit.upcase.to_s)
            end
            ndb << timetable.to_xml(as: :Ntt).indent(2) if timetable
            ndb.txtRmk(remarks) if remarks
            ndb.target!
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
