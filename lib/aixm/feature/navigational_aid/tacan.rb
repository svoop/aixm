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
      #     region: String or nil (to use +AIXM.config.region+)
      #     organisation: AIXM.organisation
      #     id: String
      #     name: String
      #     xy: AIXM.xy
      #     z: AIXM.z or nil
      #     channel: String
      #   )
      # tacan.timetable = AIXM.timetable or nil
      # tacan.remarks = String or nil
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Navigational-aid#tcn-tacan
      class TACAN < DME
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

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = to_builder
          builder.Tcn({ source: (source if AIXM.ofmx?) }.compact) do |tcn|
            tcn << to_uid.indent(2)
            tcn << organisation.to_uid.indent(2)
            tcn << vor.to_uid.indent(2) if vor
            tcn.txtName(name) if name
            tcn.codeChannel(channel)
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
