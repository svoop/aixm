using AIXM::Refinements

module AIXM
  class Feature

    # Obstacles are individual objects described as cylindrical volume with
    # circular base and height.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   obstacle = AIXM.obstacle(
    #     source: String or nil
    #     region: String or nil
    #     name: String or nil
    #     type: TYPES
    #     xy: AIXM.xy
    #     z: AIXM.z
    #     radius: AIXM.d or nil
    #   )
    #   obstacle.lighting = true or false (default for AIXM) or nil (means: unknown, default for OFMX)
    #   obstacle.lighting_remarks = String or nil
    #   obstacle.marking = true or false or nil (means: unknown, default)
    #   obstacle.marking_remarks = String or nil
    #   obstacle.height = AIXM.d or nil
    #   obstacle.height_accurate = true or false or nil (means: unknown, default)
    #   obstacle.xy_accuracy = AIXM.d or nil
    #   obstacle.z_accuracy = AIXM.d or nil
    #   obstacle.valid_from = Time or Date or String or nil
    #   obstacle.valid_until = Time or Date or String or nil
    #   obstacle.remarks = String or nil
    #   obstacle.comment = Object or nil
    #   obstacle.link_to   # => AIXM.obstacle or nil
    #   obstacle.link_type   # => LINK_TYPE or nil
    #
    # See {AIXM::Feature::ObstacleGroup} for how to define physical links
    # between two obstacles (e.g. cables between powerline towers).
    #
    # Please note: As soon as an obstacle is added to an obstacle group, the
    # +xy_accuracy+ and +z_accuracy+ of the obstacle group overwrite whatever
    # is set on the individual obstacles. On the other hand, if the obstacle
    # group has no +source+ set, it will inherit this value from the first
    # obstacle in the group.
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Obstacle
    class Obstacle < Feature
      include AIXM::Concerns::Association
      include AIXM::Concerns::Remarks

      public_class_method :new

      TYPES = {
        ANTENNA: :antenna,
        BUILDING: :building,
        CHIMNEY: :chimney,
        CRANE: :crane,
        MAST: :mast,
        TOWER: :tower,
        WINDTURBINE: :wind_turbine,
        OTHER: :other   # specify in remarks
      }.freeze

      LINK_TYPES = {
        CABLE: :cable,
        SOLID: :solid,
        OTHER: :other
      }.freeze

      # @!method obstacle_group
      #   @return [AIXM::Feature::ObstacleGroup] group this obstacle belongs to
      belongs_to :obstacle_group

      # Full name.
      #
      # @overload name
      #   @return [String]
      # @overload name=(value)
      #   @param value [String]
      attr_reader :name

      # Type of obstacle.
      #
      # @overload type
      #   @return [Symbol] any of {TYPES}
      # @overload type=(value)
      #   @param value [Symbol] any of {TYPES}
      attr_reader :type

      # Circular base center point.
      #
      # @overload xy
      #   @return [AIXM::XY]
      # @overload xy=(value)
      #   @param value [AIXM::XY]
      attr_reader :xy

      # Circular base radius.
      #
      # @overload radius
      #   @return [AIXM::D]
      # @overload radius=(value)
      #   @param value [AIXM::D]
      attr_reader :radius

      # Elevation of the top point in +:qnh+.
      #
      # @overload z
      #   @return [AIXM::Z]
      # @overload z=(value)
      #   @param value [AIXM::Z]
      attr_reader :z

      # Presence of lighting (e.g. strobes).
      #
      # @overload lighting
      #   @return [Boolean, nil] +nil+ means unknown
      # @overload lighting=(value)
      #   @param value [Boolean, nil] +nil+ means unknown
      attr_reader :lighting

      # Detailed description of the lighting.
      #
      # @overload lighting_remarks
      #   @return [String, nil]
      # @overload lighting_remarks=(value)
      #   @param value [String, nil]
      attr_reader :lighting_remarks

      # Presence of marking (e.g. red/white paint).
      #
      # @overload marking
      #   @return [Boolean, nil] +nil+ means unknown
      # @overload marking=(value)
      #   @param value [Boolean, nil] +nil+ means unknown
      attr_reader :marking

      # Detailed description of the marking.
      #
      # @overload marking_remarks
      #   @return [String nil]
      # @overload marking_remarks=(value)
      #   @param value [String, nil]
      attr_reader :marking_remarks

      # Height from ground to top point.
      #
      # @overload height
      #   @return [AIXM::D, nil]
      # @overload height=(value)
      #   @param value [AIXM::D, nil]
      attr_reader :height

      # Height accuracy.
      #
      # @overload height_accurate
      #   @return [Boolean, nil] +nil+ means unknown
      # @overload height_accurate=(value)
      #   @param value [Boolean, nil] +nil+ means unknown
      attr_reader :height_accurate

      # Margin of error for circular base center point.
      #
      # @overload xy_accuracy
      #   @return [AIXM::D, nil]
      # @overload xy_accuracy=(value)
      #   @param value [AIXM::D, nil]
      attr_reader :xy_accuracy

      # Margin of error for top point.
      #
      # @overload z_accuracy
      #   @return [AIXM::D, nil]
      # @overload z_accuracy=(value)
      #   @param value [AIXM::D, nil]
      attr_reader :z_accuracy

      # Effective after this point in time.
      #
      # @overload valid_from
      #   @return [Time, Date, String, nil]
      # @overload valid_from=(value)
      #   @param value [Time, Date, String, nil]
      attr_reader :valid_from

      # Effective until this point in time.
      #
      # @overload valid_until
      #   @return [Time, Date, String, nil]
      # @overload valid_until=(value)
      #   @param value [Time, Date, String, nil]
      attr_reader :valid_until

      # Another obstacle to which a physical link exists.
      #
      # @return [AIXM::Feature::Obstacle, nil]
      attr_reader :linked_to

      # Type of physical link between this and another obstacle.
      #
      # @return [Symbol, nil] any of {LINK_TYPES}
      attr_reader :link_type

      # See the {cheat sheet}[AIXM::Feature::Obstacle] for examples on how to
      # create instances of this class.
      def initialize(source: nil, region: nil, name: nil, type:, xy:, z:, radius: nil)
        super(source: source, region: region)
        self.name, self.type, self.xy, self.z, self.radius = name, type, xy, z, radius
        @lighting = @marking = false
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} xy="#{xy}" type=#{type.inspect} name=#{name.inspect}>)
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.nil? || value.is_a?(String)
        @name = value&.uptrans
      end

      def type=(value)
        @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def xy=(value)
        fail(ArgumentError, "invalid xy") unless value.is_a? AIXM::XY
        @xy = value
      end

      def z=(value)
        fail(ArgumentError, "invalid z") unless value.is_a?(AIXM::Z) && value.qnh?
        @z = value
      end

      def radius=(value)
        fail(ArgumentError, "invalid radius") unless value.nil? || (value.is_a?(AIXM::D) && value.dim > 0)
        @radius = value
      end

      def lighting=(value)
        fail(ArgumentError, "invalid lighting") unless [true, false, nil].include? value
        @lighting = value
      end

      def lighting_remarks=(value)
        @lighting_remarks = value&.to_s
      end

      def marking=(value)
        fail(ArgumentError, "invalid marking") unless [true, false, nil].include? value
        @marking = value
      end

      def marking_remarks=(value)
        @marking_remarks = value&.to_s
      end

      def height=(value)
        fail(ArgumentError, "invalid height") unless value.nil? || (value.is_a?(AIXM::D) && value.dim > 0)
        @height = value
      end

      def height_accurate=(value)
        fail(ArgumentError, "invalid height accurate") unless [true, false, nil].include? value
        @height_accurate = value
      end

      def xy_accuracy=(value)
        fail(ArgumentError, "invalid xy accuracy") unless value.nil? || value.is_a?(AIXM::D)
        @xy_accuracy = value
      end

      def z_accuracy=(value)
        fail(ArgumentError, "invalid z accuracy") unless value.nil? || value.is_a?(AIXM::D)
        @z_accuracy = value
      end

      def valid_from=(value)
        @valid_from = value&.to_time
      end

      def valid_until=(value)
        @valid_until = value&.to_time
      end

      def linked_to=(value)
        fail(ArgumentError, "invalid linked to") unless value.is_a?(AIXM::Feature::Obstacle)
        @linked_to = value
      end
      private :linked_to=

      def link_type=(value)
        @link_type = LINK_TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid link type")
      end
      private :link_type=

      # Whether part of an obstacle group.
      #
      # @return [Boolean]
      def grouped?
        obstacle_group && obstacle_group.obstacles.count > 1
      end

      # Whether obstacle is linked to another one.
      #
      # @return [Boolean]
      def linked?
        !!linked_to
      end

      # @!visibility private
      def add_uid_to(builder, as: :ObsUid)
        obstacle_group = self.obstacle_group || singleton_obstacle_group
        builder.send(as) do |tag|
          obstacle_group.add_uid_to(tag) if AIXM.ofmx?
          tag.geoLat((xy.lat(AIXM.schema)))
          tag.geoLong((xy.long(AIXM.schema)))
        end
      end

      # @!visibility private
      def add_to(builder, delegate: true)
        obstacle_group = self.obstacle_group || singleton_obstacle_group
        return obstacle_group.add_to(builder) if delegate && AIXM.ofmx?
        builder.comment "Obstacle: [#{type}] #{xy.to_s} #{name}".dress
        builder.text "\n"
        builder.Obs({ source: (source if AIXM.ofmx?) }.compact) do |obs|
          obs.comment(indented_comment) if comment
          add_uid_to(obs)
          obs.txtName(name) if name
          if AIXM.ofmx?
            obs.codeType(TYPES.key(type))
          else
            obs.txtDescrType(TYPES.key(type))
          end
          obs.codeGroup(grouped? ? 'Y' : 'N')
          if AIXM.ofmx?
            obs.codeLgt(lighting ? 'Y' : 'N') unless lighting.nil?
            obs.codeMarking(marking ? 'Y' : 'N') unless marking.nil?
          else
            obs.codeLgt(lighting ? 'Y' : 'N')
          end
          obs.txtDescrLgt(lighting_remarks) if lighting_remarks
          obs.txtDescrMarking(marking_remarks) if marking_remarks
          obs.codeDatum('WGE')
          if AIXM.aixm? && obstacle_group.xy_accuracy
            obs.valGeoAccuracy(obstacle_group.xy_accuracy.dim.trim)
            obs.uomGeoAccuracy(obstacle_group.xy_accuracy.unit.upcase)
          end
          obs.valElev(z.alt)
          if AIXM.aixm? && obstacle_group.z_accuracy
            obs.valElevAccuracy(obstacle_group.z_accuracy.to_ft.dim.round)
          end
          obs.valHgt(height.to_ft.dim.round) if height
          obs.uomDistVer('FT')
          if AIXM.ofmx? && !height_accurate.nil?
            obs.codeHgtAccuracy(height_accurate ? 'Y' : 'N')
          end
          if AIXM.ofmx?
            if radius
              obs.valRadius(radius.dim.trim)
              obs.uomRadius(radius.unit.upcase)
            end
            if grouped? && linked?
              linked_to.add_uid_to(obs, as: :ObsUidLink)
              obs.codeLinkType(LINK_TYPES.key(link_type))
            end
            obs.datetimeValidWef(valid_from.utc.xmlschema) if valid_from
            obs.datetimeValidTil(valid_until.utc.xmlschema) if valid_until
          end
          obs.txtRmk(remarks) if remarks
        end
      end

      private

      # OFMX requires single, ungrouped obstacles to be the only member of a
      # singleton obstacle group.
      def singleton_obstacle_group
        AIXM.obstacle_group(region: region).add_obstacle self
      end

    end
  end
end
