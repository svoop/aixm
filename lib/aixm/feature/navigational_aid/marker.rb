using AIXM::Refinements

module AIXM
  class Feature
    class NavigationalAid

      # Marker beacons guide an aircraft on a specific route e.g. towards a
      # runway (which is why marker beacons are often part of an ILS). Their
      # VHF radio beacons are transmitted on 75 MHz.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   marker = AIXM.marker(
      #     source: String or nil
      #     region: String or nil
      #     organisation: AIXM.organisation
      #     id: String
      #     name: String
      #     xy: AIXM.xy
      #     z: AIXM.z or nil
      #     type: :outer or :middle or :inner or :backcourse
      #   )
      #   marker.timetable = AIXM.timetable or nil
      #   marker.remarks = String or nil
      #
      # @note Marker are not fully implemented because they usually have to be
      #   associated with an ILS which are not implemented as of now.
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Navigational-aid#mkr-marker-beacon
      class Marker < NavigationalAid
        public_class_method :new

        TYPES = {
          O: :outer,
          M: :middle,
          I: :inner,
          C: :backcourse,
          OTHER: :other     # specify in remarks
        }

        # @return [Symbol] type of marker (see {TYPES})
        attr_reader :type

        # TODO: Marker require an associated ILS (not yet implemented)
        def initialize(type:, **arguments)
          super(**arguments)
          self.type = type
          warn("WARNING: Maker is not fully implemented yet due to the lack of ILS")
        end

        def type=(value)
          @type = value.nil? ? nil : TYPES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          insert_mid(
            builder.MkrUid({ region: (region if AIXM.ofmx?) }.compact) do |mkr_uid|
              mkr_uid.codeId(id)
              mkr_uid.geoLat(xy.lat(AIXM.schema))
              mkr_uid.geoLong(xy.long(AIXM.schema))
            end
          )
        end

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = to_builder
          builder.Mkr({ source: (source if AIXM.ofmx?) }.compact) do |mkr|
            mkr << to_uid.indent(2)
            mkr << organisation.to_uid.indent(2)
            mkr.codePsnIls(type_key.to_s) if type_key
            mkr.valFreq(75)
            mkr.uomFreq('MHZ')
            mkr.txtName(name) if name
            mkr.codeDatum('WGE')
            if z
              mkr.valElev(z.alt)
              mkr.uomDistVer(z.unit.upcase.to_s)
            end
            mkr << timetable.to_xml(as: :Mtt).indent(2) if timetable
            mkr.txtRmk(remarks) if remarks
            mkr.target!
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
