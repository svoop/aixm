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
      #   vor.comment = Object or nil
      #   vor.associate_dme     # turns the VOR into a VOR/DME
      #   vor.associate_tacan   # turns the VOR into a VORTAC
      #
      # @see https://gitlab.com/openflightmaps/ofmx/wikis/Navigational-aid#vor-vor
      class VOR < NavigationalAid
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
        #
        # @!method dme=(dme)
        #   @param dme [AIXM::Feature::NavigationalAid::DME, nil]
        has_one :dme, allow_nil: true

        # @!method tacan
        #   @return [AIXM::Feature::NavigationalAid::TACAN, nil] associated TACAN
        #
        # @!method tacan=(tacan)
        #   @param tacan [AIXM::Feature::NavigationalAid::TACAN, nil]
        has_one :tacan, allow_nil: true

        # Type of VOR
        #
        # @overload type
        #   @return [Symbol] any of {TYPES}
        # @overload type=(value)
        #   @param value [Symbol] any of {TYPES}
        attr_reader :type

        # Radio requency
        #
        # @overload f
        #   @return [AIXM::F]
        # @overload f=(value)
        #   @param value [AIXM::F]
        attr_reader :f

        # North indication
        #
        # @overload north
        #   @return [Symbol] any of {NORTHS}
        # @overload north=(value)
        #   @param value [Symbol] any of {NORTHS}
        attr_reader :north

        # See the {cheat sheet}[AIXM::Feature::VOR] for examples on how to
        # create instances of this class.
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

        # @!method associate_dme
        #   Build a DME associated to this VOR (which turns it into a VOR/DME)
        #
        #   @return [AIXM::Feature::NavigationalAid::DME] associated DME
        #
        # @!method dassociate_tacan
        #   Build a TACAN associated to this VOR (which turns it into a VORTAC)
        #
        #   @return [AIXM::Feature::NavigationalAid::TACAN] associated TACAN
        %i(dme tacan).each do |secondary|
          define_method("associate_#{secondary}") do
            send("#{secondary}=",
              AIXM.send(secondary,
                region: region,
                source: source,
                organisation: organisation,
                id: id,
                name: name,
                xy: xy,
                z: z,
                ghost_f: f
              ).tap do |navigational_aid|
                navigational_aid.timetable = timetable
                navigational_aid.remarks = remarks
              end
            )
          end
        end

        # @!visibility private
        def add_uid_to(builder)
          builder.VorUid({ region: (region if AIXM.ofmx?) }.compact) do |vor_uid|
            vor_uid.codeId(id)
            vor_uid.geoLat(xy.lat(AIXM.schema))
            vor_uid.geoLong(xy.long(AIXM.schema))
          end
        end

        # @!visibility private
        def add_to(builder)
          super
          builder.Vor({ source: (source if AIXM.ofmx?) }.compact) do |vor|
            vor.comment(indented_comment) if comment
            add_uid_to(vor)
            organisation.add_uid_to(vor)
            vor.txtName(name) if name
            vor.codeType(type_key)
            vor.valFreq(f.freq.trim)
            vor.uomFreq(f.unit.upcase)
            vor.codeTypeNorth(north_key)
            vor.codeDatum('WGE')
            if z
              vor.valElev(z.alt)
              vor.uomDistVer(z.unit.upcase)
            end
            timetable.add_to(vor, as: :Vtt) if timetable
            vor.txtRmk(remarks) if remarks
          end
          @dme.add_to(builder) if @dme
          @tacan.add_to(builder) if @tacan
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
