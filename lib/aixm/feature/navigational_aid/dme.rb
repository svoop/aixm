using AIXM::Refinements

module AIXM
  class Feature
    class NavigationalAid

      # Distance measuring equipment (DME) is a transponder-based radio navigation
      # technology which measures slant range distance by timing the propagation
      # delay of VHF or UHF signals. They operate in the frequency band between
      # 962 MHz and 1213 MHz.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   dme = AIXM.dme(
      #     source: String or nil
      #     region: String or nil
      #     organisation: AIXM.organisation
      #     id: String
      #     name: String
      #     xy: AIXM.xy
      #     z: AIXM.z or nil
      #     channel: String   # either set channel directly
      #     ghost_f: AIXM.f   # or set channel via VOR ghost frequency
      #   )
      #   dme.timetable = AIXM.timetable or nil
      #   dme.remarks = String or nil
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Navigational-aid#dme-dme
      class DME < NavigationalAid
        include AIXM::Memoize

        public_class_method :new

        CHANNEL_RE = /\A([1-9]|[1-9]\d|1[0-1]\d|12[0-6])[XY]\z/.freeze

        GHOST_MAP = {
          108_00 => (17..59),
          112_30 => (70..126),
          133_30 => (60..69),
          134_40 => (1..16)
        }.freeze

        # @!method vor
        #   @return [AIXM::Feature::NavigationalAid::VOR, nil] associated VOR
        belongs_to :vor, readonly: true

        # Radio channel
        #
        # @overload channel
        #   @return [String]
        # @overload channel=(value)
        #   @param value [String]
        # @overload ghost_f
        #   @return [AIXM::F] ghost frequency matching the {#channel}
        # @overload ghost_f=(value)
        #   @param value [AIXM::F] ghost frequency matching the {#channel}
        attr_reader :channel

        # See the {cheat sheet}[AIXM::Feature::NavigationalAid::DME] for examples
        # on how to create instances of this class.
        def initialize(channel: nil, ghost_f: nil, **arguments)
          super(**arguments)
          case
            when channel then self.channel = channel
            when ghost_f then self.ghost_f = ghost_f
            else fail(ArgumentError, "either channel or ghost_f must be set")
          end
        end

        def channel=(value)
          fail(ArgumentError, "invalid channel") unless value.is_a?(String) && value.match?(CHANNEL_RE)
          @channel = value
        end

        def ghost_f=(value)
          fail(ArgumentError, "invalid ghost_f") unless value.is_a?(AIXM::F) && value.unit == :mhz
          integer, letter = (value.freq * 100).round, 'X'
          unless (integer % 10).zero?
            integer -= 5
            letter = 'Y'
          end
          base = GHOST_MAP.keys.reverse.bsearch { _1 <= integer }
          number = ((integer - base) / 10) + GHOST_MAP[base].min
          self.channel = "#{number}#{letter}"
        end

        def ghost_f
          if channel
            number, letter = channel.split(/(?=[XY])/)
            integer = GHOST_MAP.find { _2.include?(number.to_i) }.first
            integer += (number.to_i - GHOST_MAP[integer].min) * 10
            integer += 5 if letter == 'Y'
            AIXM.f(integer.to_f / 100, :mhz)
          end
        end

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.DmeUid({ region: (region if AIXM.ofmx?) }.compact) do |dme_uid|
            dme_uid.codeId(id)
            dme_uid.geoLat(xy.lat(AIXM.schema))
            dme_uid.geoLong(xy.long(AIXM.schema))
          end
        end
        memoize :to_uid

        # @return [String] AIXM or OFMX markup
        def to_xml
          builder = to_builder
          builder.Dme({ source: (source if AIXM.ofmx?) }.compact) do |dme|
            dme << to_uid.indent(2)
            dme << organisation.to_uid.indent(2)
            dme << vor.to_uid.indent(2) if vor
            dme.txtName(name) if name
            dme.codeChannel(channel)
            unless vor
              dme.valGhostFreq(ghost_f.freq.trim)
              dme.uomGhostFreq('MHZ')
            end
            dme.codeDatum('WGE')
            if z
              dme.valElev(z.alt)
              dme.uomDistVer(z.unit.upcase.to_s)
            end
            dme << timetable.to_xml(as: :Dtt).indent(2) if timetable
            dme.txtRmk(remarks) if remarks
            dme.target!
          end
        end
      end

    end
  end
end
