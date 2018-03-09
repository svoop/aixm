using AIXM::Refinements

module AIXM
  module Feature
    module NavigationalAid

      ##
      # VOR (VHF omnidirectional range) operate in the frequency band between
      # 108.00 Mhz to 117.95 MHz. Two type of VORs exist:
      #
      # Types:
      # * +:vor+ (+:VOR+) - conventional VOR (also known as CVOR)
      # * +:doppler_vor+ (+:DVOR+) - Doppler VOR
      #
      # North types:
      # * +:geographic+ (+:TRUE+) - VOR aligned towards geographic north
      # * +:grid+ (+:GRID+) - VOR aligned along north-south lines of the
      #                       universal transverse mercator grid imposed on
      #                       topographic maps by the USA and NATO
      # * +:magnetic+ (+:MAG+) - VOR aligned towards magnetic north
      #
      # https://en.wikipedia.org/wiki/VHF_omnidirectional_range
      class VOR < Base
        TYPES = {
          VOR: :conventional,
          DVOR: :doppler
        }.freeze

        NORTHS = {
          TRUE: :geographic,
          GRID: :grid,
          MAG: :magnetic
        }.freeze

        attr_reader :type, :f, :north, :dme, :tacan

        public_class_method :new

        def initialize(id:, name:, xy:, z: nil, type:, f:, north:)
          super(id: id, name: name, xy: xy, z: z)
          self.type, self.f, self.north = type, f, north
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def type_key
          TYPES.key(type)
        end

        def f=(value)
          fail(ArgumentError, "invalid f") unless value.is_a?(F) && value.between?(108, 117.95, :mhz)
          @f = value
        end

        def north=(value)
          @north = NORTHS.lookup(value&.to_sym, nil) || fail(ArgumentError, "invalid north")
        end

        def north_key
          NORTHS.key(north)
        end

        ##
        # Associate a DME (also known as VOR/DME)
        def associate_dme(channel:)
          @dme = AIXM.dme(id: id, name: name, xy: xy, z: z, channel: channel)
          @dme.schedule = schedule
          @dme.remarks = remarks
          @dme.vor = self
        end

        ##
        # Associate a TACAN (also known as VORTAC)
        def associate_tacan(channel:)
          @tacan = AIXM.tacan(id: id, name: name, xy: xy, z: z, channel: channel)
          @tacan.schedule = schedule
          @tacan.remarks = remarks
          @tacan.vor = self
        end

        def to_digest
          [super, type, f, north].to_digest
        end

        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.VorUid(mid: to_digest) do |voruid|
            voruid.codeId(id)
            voruid.geoLat(xy.lat(AIXM.format))
            voruid.geoLong(xy.long(AIXM.format))
          end
        end

        def to_xml
          builder = to_builder
          builder.Vor do |vor|
            vor << to_uid.indent(2)
            vor.OrgUid
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
            if schedule
              vor.Vtt do |vtt|
                vtt << schedule.to_xml.indent(4)
              end
            end
            vor.txtRmk(remarks) if remarks
          end
          builder << @dme.to_xml if @dme
          builder << @tacan.to_xml if @tacan
          builder.target!   # see https://github.com/jimweirich/builder/issues/42
        end
      end

    end
  end
end
