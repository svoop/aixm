module AIXM
  module Feature
    module NavigationalAid

      ##
      # Marker (marker beacons) operate on 75 MHz.
      #
      # Types:
      # * +:outer+ (+:O+) - outer marker
      # * +:middle+ (+:M+) - middle marker
      # * +:inner+ (+:I+) - inner marker
      # * +:backcourse+ (+:C+) - backcourse marker
      #
      # https://en.wikipedia.org/wiki/Marker_beacon
      class Marker < Base
        using AIXM::Refinements

        TYPES = {
          O: :outer,
          M: :middle,
          I: :inner,
          C: :backcourse
        }

        attr_reader :type

        public_class_method :new

        # TODO: Marker require an associated ILS
        def initialize(id:, name:, xy:, z: nil, type:)
          super(id: id, name: name, xy: xy, z: z)
          self.type = type
          warn("WARNING: Maker is not fully implemented yet due to the lack of ILS")
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def type_key
          TYPES.key(type)
        end

        ##
        # Render UID markup
        def to_uid(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.MkrUid({ mid: to_digest, newEntity: (true if extensions >> :ofm) }.compact) do |mkruid|
            mkruid.codeId(id)
            mkruid.geoLat(xy.lat(format_for(*extensions)))
            mkruid.geoLong(xy.long(format_for(*extensions)))
          end
        end

        ##
        # Render AIXM markup
        def to_aixm(*extensions)
          builder = to_builder(*extensions)
          builder.Mkr do |mkr|
            mkr << to_uid(*extensions).indent(2)
            mkr.OrgUid
            mkr.codePsnIls(type_key.to_s)
            mkr.valFreq(75)
            mkr.uomFreq('MHZ')
            mkr.txtName(name) if name
            mkr.codeDatum('WGE')
            if z
              mkr.valElev(z.alt)
              mkr.uomDistVer(z.unit.to_s)
            end
            if schedule
              mkr.Mtt do |mtt|
                mtt << schedule.to_aixm(*extensions).indent(4)
              end
            end
            mkr.txtRmk(remarks) if remarks
            mkr.target!   # see https://github.com/jimweirich/builder/issues/42
          end
        end
      end

    end
  end
end
