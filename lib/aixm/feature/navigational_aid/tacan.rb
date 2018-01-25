module AIXM
  module Feature
    module NavigationalAid

      ##
      # TACAN (tactical air navigation system) operate in the frequency band
      # between 960 MHz and 1215 MHz.
      #
      # https://en.wikipedia.org/wiki/Tactical_air_navigation_system
      class TACAN < Base
        using AIXM::Refinements

        attr_reader :channel

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, channel:)
          super(id: id, name: name, xy: xy, z: z)
          @channel = channel&.upcase
        end

        ##
        # Digest to identify the payload
        def to_digest
          [super, channel].to_digest
        end

        ##
        # Render AIXM
        def to_xml(*extensions)
          builder = to_builder(*extensions)
          builder.Tcn do |tcn|
            tcn.TcnUid({ newEntity: (true if extensions >> :ofm) }.compact) do |tcnuid|
              tcnuid.codeId(id)
              tcnuid.geoLat(xy.lat(format_for(*extensions)))
              tcnuid.geoLong(xy.long(format_for(*extensions)))
            end
            tcn.OrgUid
            tcn.txtName(name)
            tcn.codeChannel(channel)
            tcn.codeDatum('WGE')
            if z
              tcn.valElev(z.alt)
              tcn.uomDistVer(z.unit.to_s)
            end
            if schedule
              tcn.Ttt do |ttt|
                ttt << schedule.to_xml(*extensions).indent(4)
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
