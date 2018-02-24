module AIXM
  module Feature
    module NavigationalAid

      ##
      # TACAN (tactical air navigation system) can be used as a DME by civilian
      # aircraft and therefore operate in the frequency band between 960 MHz
      # and 1215 MHz.
      #
      # https://en.wikipedia.org/wiki/Tactical_air_navigation_system
      class TACAN < DME
        using AIXM::Refinements

        public_class_method :new

        ##
        # Render UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.TcnUid({ mid: to_digest, newEntity: (true if AIXM.ofmx?) }.compact) do |tcnuid|
            tcnuid.codeId(id)
            tcnuid.geoLat(xy.lat(AIXM.format))
            tcnuid.geoLong(xy.long(AIXM.format))
          end
        end

        ##
        # Render XML
        def to_xml
          builder = to_builder
          builder.Tcn do |tcn|
            tcn << to_uid.indent(2)
            tcn.OrgUid
            tcn << vor.to_uid.indent(2) if vor
            tcn.txtName(name) if name
            tcn.codeChannel(channel)
            tcn.codeDatum('WGE')
            if z
              tcn.valElev(z.alt)
              tcn.uomDistVer(z.unit.to_s)
            end
            if schedule
              tcn.Ttt do |ttt|
                ttt << schedule.to_xml.indent(4)
              end
            end
            tcn.txtRmk(remarks) if remarks
            tcn.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end
      end

    end
  end
end
