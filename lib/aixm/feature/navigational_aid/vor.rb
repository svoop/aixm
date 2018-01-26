module AIXM
  module Feature
    module NavigationalAid

      ##
      # VOR (VHF omnidirectional range) operate in the frequency band between
      # 108.00 Mhz to 117.95 MHz. Two type of VORs exist:
      #
      # Types:
      # * +:vor+ (+:VOR+) - standard VOR
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
        using AIXM::Refinements

        TYPES = {
          VOR: :vor,
          DVOR: :doppler_vor
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

        ##
        # Digest to identify the payload
        def to_digest
          [super, type, f.to_digest, north].to_digest
        end

        ##
        # Render UID markup
        def to_uid(*extensions)
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.VorUid({ newEntity: (true if extensions >> :ofm) }.compact) do |voruid|
            voruid.codeId(id)
            voruid.geoLat(xy.lat(format_for(*extensions)))
            voruid.geoLong(xy.long(format_for(*extensions)))
          end
        end

        ##
        # Render AIXM markup
        def to_aixm(*extensions)
          builder = to_builder(*extensions)
          builder.Vor do |vor|
            vor << to_uid(*extensions).indent(2)
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
                vtt << schedule.to_aixm(*extensions).indent(4)
              end
            end
            vor.txtRmk(remarks) if remarks
          end
          builder << @dme.to_aixm(*extensions) if @dme
          builder << @tacan.to_aixm(*extensions) if @tacan
          builder.target!   # see https://github.com/jimweirich/builder/issues/42
        end
      end

    end
  end
end
