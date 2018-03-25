using AIXM::Refinements

module AIXM
  module Feature
    module NavigationalAid

      ##
      # TACAN (tactical air navigation system) can be used as a DME by civilian
      # aircraft and therefore operate in the frequency band between 960 MHz
      # and 1215 MHz.
      # https://en.wikipedia.org/wiki/Tactical_air_navigation_system
      #
      # Arguments:
      # * +channel+ - radio channel (e.g. "3X")
      #
      # Don't use +vor=+! Instantiate a VOR and then invoke +assign_tacan+ on
      # it instead.
      class TACAN < DME
        public_class_method :new

        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.TcnUid do |tcnuid|
            tcnuid.codeId(id)
            tcnuid.geoLat(xy.lat(AIXM.format))
            tcnuid.geoLong(xy.long(AIXM.format))
          end
        end

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
              tcn << schedule.to_xml(as: :Ttt).indent(2)
            end
            tcn.txtRmk(remarks) if remarks
            tcn.target!
          end
        end
      end

    end
  end
end
