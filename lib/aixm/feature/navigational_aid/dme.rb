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
      #     region: String or nil (falls back to AIXM.config.region)
      #     organisation: AIXM.organisation
      #     id: String
      #     name: String
      #     xy: AIXM.xy
      #     z: AIXM.z or nil
      #     channel: String
      #   )
      #   dme.schedule = AIXM.schedule or nil
      #   dme.remarks = String or nil
      #
      # @see https://github.com/openflightmaps/ofmx/wiki/Navigational-aid#dme-dme
      class DME < NavigationalAid
        public_class_method :new

        # @return [String] radio channel
        attr_reader :channel

        # @return [AIXM::Feature::NavigationalAid::VOR] associated VOR
        attr_reader :vor

        def initialize(channel:, **arguments)
          super(**arguments)
          self.channel = channel
        end

        def channel=(value)
          fail(ArgumentError, "invalid channel") unless value.is_a? String
          @channel = value.upcase
        end

        def vor=(value)
          fail(ArgumentError, "invalid VOR") unless value.is_a? VOR
          @vor = value
        end
        private :vor=

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.DmeUid({ region: (region if AIXM.ofmx?) }.compact) do |dme_uid|
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
            dme.codeDatum('WGE')
            if z
              dme.valElev(z.alt)
              dme.uomDistVer(z.unit.upcase.to_s)
            end
            dme << schedule.to_xml(as: :Dtt).indent(2) if schedule
            dme.txtRmk(remarks) if remarks
            dme.target!
          end
        end
      end

    end
  end
end
