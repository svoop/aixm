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
        def initialize(type:, **arguments)
          super(**arguments)
          self.type = type
          warn("WARNING: Maker is not fully implemented yet due to the lack of ILS")
        end

        ##
        # Type of marker
        #
        # Allowed values:
        # * +:outer+ (+:O+) - outer marker
        # * +:middle+ (+:M+) - middle marker
        # * +:inner+ (+:I+) - inner marker
        # * +:backcourse+ (+:C+) - backcourse marker
        # * +:other+ (+:OTHER+) - specify in +remarks+
        def type=(value)
          @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def type_key
          TYPES.key(type)
        end

        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.MkrUid({ region: (region if AIXM.ofmx?) }.compact) do |mkr_uid|
            mkr_uid.codeId(id)
            mkr_uid.geoLat(xy.lat(AIXM.schema))
            mkr_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        def to_xml
          builder = to_builder
          builder.Mkr({ source: (source if AIXM.ofmx?) }.compact) do |mkr|
            mkr << to_uid.indent(2)
            mkr << organisation.to_uid.indent(2)
            mkr.codePsnIls(type_key.to_s)
            mkr.valFreq(75)
            mkr.uomFreq('MHZ')
            mkr.txtName(name) if name
            mkr.codeDatum('WGE')
            if z
              mkr.valElev(z.alt)
              mkr.uomDistVer(z.unit.to_s)
            end
            mkr << schedule.to_xml(as: :Mtt).indent(2) if schedule
            mkr.txtRmk(remarks) if remarks
            mkr.target!
          end
        end
      end

    end
  end
end
