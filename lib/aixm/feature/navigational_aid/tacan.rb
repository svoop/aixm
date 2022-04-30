using AIXM::Refinements

module AIXM
  class Feature
    class NavigationalAid

      # TACAN (tactical air navigation system) are military systems which also
      # provide DME service to civilian aircraft and therefore operate in the
      # frequency band between 960 MHz and 1215 MHz.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   tacan = AIXM.tacan(
      #     source: String or nil
      #     region: String or nil
      #     organisation: AIXM.organisation
      #     id: String
      #     name: String
      #     xy: AIXM.xy
      #     z: AIXM.z or nil
      #     channel: String   # either set channel directly
      #     ghost_f: AIXM.f   # or set channel via VOR ghost frequency
      #   )
      #   tacan.timetable = AIXM.timetable or nil
      #   tacan.remarks = String or nil
      #   tacan.comment = Object or nil
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Navigational-aid#tcn-tacan
      class TACAN < DME
        public_class_method :new

        # @!visibility private
        def add_uid_to(builder)
          builder.TcnUid({ region: (region if AIXM.ofmx?) }.compact) do |tcn_uid|
            tcn_uid.codeId(id)
            tcn_uid.geoLat(xy.lat(AIXM.schema))
            tcn_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        # @!visibility private
        def add_to(builder)
          builder.comment "NavigationalAid: [#{kind}] #{[id, name].compact.join(' / ')}".dress
          builder.text "\n"
          builder.Tcn({ source: (source if AIXM.ofmx?) }.compact) do |tcn|
            tcn.comment(indented_comment) if comment
            add_uid_to(tcn)
            organisation.add_uid_to(tcn)
            vor.add_uid_to(tcn) if vor
            tcn.txtName(name) if name
            tcn.codeChannel(channel)
            if !vor && AIXM.ofmx?
              tcn.valGhostFreq(ghost_f.freq.trim)
              tcn.uomGhostFreq('MHZ')
            end
            tcn.codeDatum('WGE')
            if z
              tcn.valElev(z.alt)
              tcn.uomDistVer(z.unit.upcase)
            end
            timetable.add_to(tcn, as: :Ttt) if timetable
            tcn.txtRmk(remarks) if remarks
          end
        end
      end

    end
  end
end
