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
      #   marker.comment = Object or nil
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

        # Type of marker
        #
        # @overload type
        #   @return [Symbol, nil] any of {TYPES}
        # @overload type=(value)
        #   @param value [Symbol, nil] any of {TYPES}
        attr_reader :type

        # See the {cheat sheet}[AIXM::Feature::NavigationalAid::Marker] for
        # examples on how to create instances of this class.
        def initialize(type:, **arguments)
          super(**arguments)
          self.type = type
          # TODO: Marker require an associated ILS (not yet implemented)
          warn("WARNING: Marker is not fully implemented yet due to the lack of ILS")
        end

        def type=(value)
          @type = value.nil? ? nil : TYPES.lookup(value.to_s.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        # @!visibility private
        def add_uid_to(builder)
          builder.MkrUid({ region: (region if AIXM.ofmx?) }.compact) do |mkr_uid|
            mkr_uid.codeId(id)
            mkr_uid.geoLat(xy.lat(AIXM.schema))
            mkr_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        # @!visibility private
        def add_to(builder)
          super
          builder.Mkr({ source: (source if AIXM.ofmx?) }.compact) do |mkr|
            mkr.comment(indented_comment) if comment
            add_uid_to(mkr)
            organisation.add_uid_to(mkr)
            mkr.codePsnIls(type_key) if type_key
            mkr.valFreq(75)
            mkr.uomFreq('MHZ')
            mkr.txtName(name) if name
            mkr.codeDatum('WGE')
            if z
              mkr.valElev(z.alt)
              mkr.uomDistVer(z.unit.upcase)
            end
            timetable.add_to(mkr, as: :Mtt) if timetable
            mkr.txtRmk(remarks) if remarks
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
