using AIXM::Refinements

module AIXM
  class Feature
    class NavigationalAid

      # VHF omni directional radio range (VOR) is a type of radio navigation for
      # aircraft to determine their position and course. They operate in the
      # frequency band between 108.00 Mhz to 117.95 MHz.
      #
      # ===Cheat Sheet in Pseudo Code:
      #   vor = AIXM.vor(
      #     source: String or nil
      #     region: String or nil
      #     organisation: AIXM.organisation
      #     id: String
      #     name: String
      #     xy: AIXM.xy
      #     z: AIXM.z or nil
      #     type: TYPES
      #     f: AIXM.f
      #     north: NORTHS
      #   )
      #   vor.timetable = AIXM.timetable or nil
      #   vor.remarks = String or nil
      #   vor.associate_dme(channel: String)     # turns the VOR into a VOR/DME
      #   vor.associate_tacan(channel: String)   # turns the VOR into a VORTAC
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Navigational-aid#vor-vor
      class VOR < NavigationalAid
        include AIXM::Memoize
        
        public_class_method :new

        TYPES = {
          VOR: :conventional,
          DVOR: :doppler,
          OTHER: :other         # specify in remarks
        }.freeze

        NORTHS = {
          TRUE: :geographic,
          GRID: :grid,         # parallel to the north-south lines of the UTM grid
          MAG: :magnetic,
          OTHER: :other        # specify in remarks
        }.freeze

        # @!method dme
        #   @return [AIXM::Feature::NavigationalAid::DME, nil] associated DME
        # @!method dme=(dme)
        #   @param dme [AIXM::Feature::NavigationalAid::DME, nil]
        has_one :dme, allow_nil: true

        # @!method tacan
        #   @return [AIXM::Feature::NavigationalAid::TACAN, nil] associated TACAN
        # @!method tacan=(tacan)
        #   @param tacan [AIXM::Feature::NavigationalAid::TACAN, nil]
        has_one :tacan, allow_nil: true

        # @return [Symbol] type of VOR (see {TYPES})
        attr_reader :type

        # @return [AIXM::F] radio requency
        attr_reader :f

        # @return [Symbol] north indication (see {NORTHS})
        attr_reader :north

        def initialize(type:, f:, north:, **arguments)
          super(**arguments)
          self.type, self.f, self.north = type, f, north
        end

        def type=(value)
          @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
        end

        def f=(value)
          fail(ArgumentError, "invalid f") unless value.is_a?(F) && value.between?(108, 117.95, :mhz)
          @f = value
        end

        def north=(value)
          @north = NORTHS.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid north")
        end

        # Associate a DME which turns the VOR into a VOR/DME
        def associate_dme(channel:)
          self.dme = AIXM.dme(region: region, organisation: organisation, id: id, name: name, xy: xy, z: z, channel: channel)
          dme.timetable, @dme.remarks = timetable, remarks
        end

        # Associate a TACAN which turns the VOR into a VORTAC
        def associate_tacan(channel:)
          self.tacan = AIXM.tacan(region: region, organisation: organisation, id: id, name: name, xy: xy, z: z, channel: channel)
          tacan.timetable, @tacan.remarks = timetable, remarks
        end

        # @return [String] UID markup
        def to_uid
          builder = Builder::XmlMarkup.new(indent: 2)
          builder.VorUid({ region: (region if AIXM.ofmx?) }.compact) do |vor_uid|
            vor_uid.codeId(id)
            vor_uid.geoLat(xy.lat(AIXM.schema))
            vor_uid.geoLong(xy.long(AIXM.schema))
          end
        end
        memoize :to_uid

        # @return [String] AIXM or OFMX markup
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
              vor.uomDistVer(z.unit.upcase.to_s)
            end
            vor << timetable.to_xml(as: :Vtt).indent(2) if timetable
            vor.txtRmk(remarks) if remarks
          end
          builder << @dme.to_xml if @dme
          builder << @tacan.to_xml if @tacan
          builder.target!
        end

        # @api private
        def type_key
          TYPES.key(type)
        end

        # @api private
        def north_key
          NORTHS.key(north)
        end
      end

    end
  end
end
