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
        def to_uid(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.TcnUid({ mid: to_digest, newEntity: (true if extensions >> :ofm) }.compact) do |tcnuid|
            tcnuid.codeId(id)
            tcnuid.geoLat(xy.lat(format_for(*extensions)))
            tcnuid.geoLong(xy.long(format_for(*extensions)))
          end
        end

        ##
        # Render AIXM markup
        def to_aixm(*extensions)
          builder = to_builder(*extensions)
          builder.Tcn do |tcn|
            tcn << to_uid(*extensions).indent(2)
            tcn.OrgUid
            tcn << vor.to_uid(*extensions).indent(2) if vor
            tcn.txtName(name) if name
            tcn.codeChannel(channel)
            tcn.codeDatum('WGE')
            if z
              tcn.valElev(z.alt)
              tcn.uomDistVer(z.unit.to_s)
            end
            if schedule
              tcn.Ttt do |ttt|
                ttt << schedule.to_aixm(*extensions).indent(4)
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
