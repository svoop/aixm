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
      #     organisation: AIXM.organisation
      #     id: String
      #     name: String
      #     xy: AIXM.xy
      #     z: AIXM.z or nil
      #     channel: String
      #   )
      #   dme.timetable = AIXM.timetable or nil
      #   dme.remarks = String or nil
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Navigational-aid#dme-dme
      class DME < NavigationalAid
        public_class_method :new

        CHANNEL_PATTERN = /\A([1-9]|[1-9]\d|1[0-1]\d|12[0-6])[XY]\z/.freeze

        # @return [String] radio channel
        attr_reader :channel

        # @return [AIXM::Feature::NavigationalAid::VOR, nil] associated VOR
        attr_reader :vor

        def initialize(channel:, **arguments)
          super(**arguments)
          self.channel = channel
        end

        def channel=(value)
          fail(ArgumentError, "invalid channel") unless value.is_a?(String) && value.match?(CHANNEL_PATTERN)
          @channel = value
        end

        # @return [AIXM::F] ghost frequency matching the channel
        def ghost_f
          if channel
            number, letter = channel.split(/(?=[XY])/)
            integer = case number.to_i
              when (1..16) then 13430
              when (17..59) then 10630
              when (60..69) then 12730
              when (70..126) then 10530
            end
            integer += number.to_i * 10
            integer += 5 if letter == 'Y'
            AIXM.f(integer.to_f / 100, :mhz)
          end
        end

        def vor=(value)
          fail(ArgumentError, "invalid VOR") unless value.is_a? VOR
          @vor = value
        end
        private :vor=

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.DmeUid do |dme_uid|
            dme_uid.codeId(id)
            dme_uid.geoLat(xy.lat(AIXM.schema))
            dme_uid.geoLong(xy.long(AIXM.schema))
          end
        end

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
