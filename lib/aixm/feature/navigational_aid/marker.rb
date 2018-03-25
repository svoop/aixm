using AIXM::Refinements

module AIXM
  module Feature
    module NavigationalAid

      ##
      # Marker (marker beacons) operate on 75 MHz.
      # https://en.wikipedia.org/wiki/Marker_beacon
      #
      # Arguments:
      # * +type+ - type of marker
      #
      # Types:
      # * +:outer+ (+:O+) - outer marker
      # * +:middle+ (+:M+) - middle marker
      # * +:inner+ (+:I+) - inner marker
      # * +:backcourse+ (+:C+) - backcourse marker
      # * +:other+ (+:OTHER+) - see remarks
      #

      class Marker < Base
        TYPES = {
          O: :outer,
          M: :middle,
          I: :inner,
          C: :backcourse,
          OTHER: :other
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

        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.MkrUid do |mkruid|
            mkruid.codeId(id)
            mkruid.geoLat(xy.lat(AIXM.format))
            mkruid.geoLong(xy.long(AIXM.format))
          end
        end

        def to_xml
          builder = to_builder
          builder.Mkr do |mkr|
            mkr << to_uid.indent(2)
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
                mtt << schedule.to_xml.indent(4)
              end
            end
            mkr.txtRmk(remarks) if remarks
            mkr.target!
          end
        end
      end

    end
  end
end
