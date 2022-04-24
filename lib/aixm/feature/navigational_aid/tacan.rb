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
        include AIXM::Memoize

        public_class_method :new

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.TcnUid({ region: (region if AIXM.ofmx?) }.compact) do |tcn_uid|
            tcn_uid.codeId(id)
            tcn_uid.geoLat(xy.lat(AIXM.schema))
            tcn_uid.geoLong(xy.long(AIXM.schema))
          end
        end
        memoize :to_uid

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = to_builder
          builder.Tcn({ source: (source if AIXM.ofmx?) }.compact) do |tcn|
            tcn.comment!(indented_comment) if comment
            tcn << to_uid.indent(2)
            tcn << organisation.to_uid.indent(2)
            tcn << vor.to_uid.indent(2) if vor
            tcn.txtName(name) if name
            tcn.codeChannel(channel)
            if !vor && AIXM.ofmx?
              tcn.valGhostFreq(ghost_f.freq.trim)
              tcn.uomGhostFreq('MHZ')
            end
            tcn.codeDatum('WGE')
            if z
              tcn.valElev(z.alt)
              tcn.uomDistVer(z.unit.upcase.to_s)
            end
            tcn << timetable.to_xml(as: :Ttt).indent(2) if timetable
            tcn.txtRmk(remarks) if remarks
            tcn.target!
          end
        end
      end

    end
  end
end
