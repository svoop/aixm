using AIXM::Refinements

module AIXM
  module Feature
    module NavigationalAid

      ##
      # VOR (VHF omnidirectional range) operate in the frequency band between
      # 108.00 Mhz to 117.95 MHz.
      # https://en.wikipedia.org/wiki/VHF_omnidirectional_range
      #
      # Arguments:
      # * +type+ - type of VOR
      # * +f+ - radio frequency
      # * +north+ - north alignment
      class VOR < Base
        TYPES = {
          VOR: :conventional,
          DVOR: :doppler,
          OTHER: :other
        }.freeze

        NORTHS = {
          TRUE: :geographic,
          GRID: :grid,
          MAG: :magnetic,
          OTHER: :other
        }.freeze

        attr_reader :type, :f, :north, :dme, :tacan

        public_class_method :new

        def initialize(type:, f:, north:, **arguments)
          super(**arguments)
          self.type, self.f, self.north = type, f, north
        end

        ##
        # Type of VOR
        #
        # Allowed values:
        # * +:conventional+ (+:VOR+) - conventional VOR (also known as CVOR)
        # * +:doppler+ (+:DVOR+) - Doppler VOR
        # * +:other+ (+:OTHER+) - specify in +remarks+
        def type=(value)
          @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def type_key
          TYPES.key(type)
        end

        ##
        # Radio frequency
        def f=(value)
          fail(ArgumentError, "invalid f") unless value.is_a?(F) && value.between?(108, 117.95, :mhz)
          @f = value
        end

        ##
        # North alignment
        # * +:geographic+ (+:TRUE+) - VOR aligned towards geographic north
        # * +:grid+ (+:GRID+) - VOR aligned along north-south lines of the
        #                       universal transverse mercator grid imposed on
        #                       topographic maps by the USA and NATO
        # * +:magnetic+ (+:MAG+) - VOR aligned towards magnetic north
        # * +:other+ (+:OTHER+) - specify in +remarks+
        def north=(value)
          @north = NORTHS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid north")
        end

        def north_key
          NORTHS.key(north)
        end

        ##
        # Associate a DME (also known as VOR/DME)
        def associate_dme(channel:)
          @dme = AIXM.dme(organisation: organisation, id: id, name: name, xy: xy, z: z, channel: channel)
          @dme.region, @dme.schedule, @dme.remarks = region, schedule, remarks
          @dme.send(:vor=, self)
        end

        ##
        # Associate a TACAN (also known as VORTAC)
        def associate_tacan(channel:)
          @tacan = AIXM.tacan(organisation: organisation, id: id, name: name, xy: xy, z: z, channel: channel)
          @tacan.region, @tacan.schedule, @tacan.remarks = region, schedule, remarks
          @tacan.send(:vor=, self)
        end

        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.VorUid({ region: (region if AIXM.ofmx?) }.compact) do |vor_uid|
            vor_uid.codeId(id)
            vor_uid.geoLat(xy.lat(AIXM.schema))
            vor_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        def to_xml
          builder = to_builder
          builder.Vor({ source: (source if AIXM.ofmx?) }.compact) do |vor|
            vor << to_uid.indent(2)
            vor << organisation.to_uid.indent(2)
            vor.txtName(name) if name
            vor.codeType(type_key.to_s)
            vor.valFreq(f.freq.trim)
            vor.uomFreq(f.unit.upcase.to_s)
            vor.codeTypeNorth(north_key.to_s)
            vor.codeDatum('WGE')
            if z
              vor.valElev(z.alt)
              vor.uomDistVer(z.unit.to_s)
            end
            vor << schedule.to_xml(as: :Vtt).indent(2) if schedule
            vor.txtRmk(remarks) if remarks
          end
          builder << @dme.to_xml if @dme
          builder << @tacan.to_xml if @tacan
          builder.target!
        end
      end

    end
  end
end
