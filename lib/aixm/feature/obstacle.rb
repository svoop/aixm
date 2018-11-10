using AIXM::Refinements

module AIXM
  class Feature

    # Obstacles are individual objects described as cylindrical volume with
    # circular base and height.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   obstacle = AIXM.obstacle(
    #     source: String or nil
    #     name: String or nil
    #     type: TYPES
    #     xy: AIXM.xy
    #     radius: AIXM.d
    #     z: AIXM.z
    #   )
    #   obstacle.lighting = true or false (default for AIXM) or nil (means: unknown, default for OFMX)
    #   obstacle.lighting_remarks = String or nil
    #   obstacle.marking = true or false or nil (means: unknown, default)
    #   obstacle.marking_remarks = String or nil
    #   obstacle.height = AIXM.d or nil
    #   obstacle.xy_accuracy = AIXM.d or nil
    #   obstacle.z_accuracy = AIXM.d or nil
    #   obstacle.height_accurate = true or false or nil (means: unknown, default)
    #   obstacle.valid_from = Time or Date or String or nil
    #   obstacle.valid_until = Time or Date or String or nil
    #   obstacle.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Obstacle
    class Obstacle < Feature
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

      # @return [String] full name
      attr_reader :name

      # @return [Symbol] type of obstacle
      attr_reader :type

      # @return [AIXM::XY] circular base center point
      attr_reader :xy

      # @return [AIXM::D] circular base radius
      attr_reader :radius

      # @return [AIXM::Z] elevation of the top point in +:qnh+
      attr_reader :z

      # @return [Boolean, nil] lighting (e.g. strobes)
      #   true => lighting present, false => no lighting, nil => unknown
      attr_reader :lighting

      # @return [String, nil] detailed description of the lighting
      attr_reader :lighting_remarks

      # @return [Boolean, nil] marking (e.g. red/white paint)
      #  true => marking present, false => no marking, nil => unknown
      attr_reader :marking

      # @return [String, nil] detailed description of the marking
      attr_reader :marking_remarks

      # @return [AIXM::D, nil] height from ground to top point
      attr_reader :height

      # @return [AIXM::D, nil] margin of error for circular base center point
      attr_reader :xy_accuracy

      # @return [AIXM::D, nil] margin of error for top point
      attr_reader :z_accuracy

      # @return [Boolean, nil] height accuracy
      #   true => height measured, false => height estimated, nil => unknown
      attr_reader :height_accurate

      # @return [Time, Date, String, nil] effective after this point in time
      attr_reader :valid_from

      # @return [Time, Date, String, nil] effective until this point in time
      attr_reader :valid_until

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(source: nil, name: nil, type:, xy:, radius:, z:)
        super(source: source)
        self.name, self.type, self.xy, self.radius, self.z = name, type, xy, radius, z
        @lighting = @marking = @height_accurate = false
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} xy="#{xy.to_s}" type=#{type.inspect}>)
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

      def radius=(value)
        fail(ArgumentError, "invalid radius") unless value.is_a?(AIXM::D) && value.dist > 0
        @radius = value
      end

      def z=(value)
        fail(ArgumentError, "invalid z") unless value.is_a?(AIXM::Z) && value.qnh?
        @z = value
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
        fail(ArgumentError, "invalid height") unless value.nil? || (value.is_a?(AIXM::D) && value.dist > 0)
        @height = value
      end

      def xy_accuracy=(value)
        fail(ArgumentError, "invalid xy accuracy") unless value.nil? || value.is_a?(AIXM::D)
        @xy_accuracy = value
      end

      def z_accuracy=(value)
        fail(ArgumentError, "invalid z accuracy") unless value.nil? || value.is_a?(AIXM::D)
        @z_accuracy = value
      end

      def height_accurate=(value)
        fail(ArgumentError, "invalid height accurate") unless [true, false, nil].include? value
        @height_accurate = value
      end

      def valid_from=(value)
        @valid_from = value&.to_time
      end

      def valid_until=(value)
        @valid_until = value&.to_time
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [Boolean] estimation whether one obstacle (e.g. single tree) or
      #    a cluster of obstacles (e.g. a few trees)
      def clustered?
        height && radius > height
      end

      # @return [Boolean] whether part of an obstacle group
      def grouped?
        respond_to? :group
      end

      # @return [String] UID markup
      def to_uid(as: :ObsUid)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag.geoLat((xy.lat(AIXM.schema)))
          tag.geoLong((xy.long(AIXM.schema)))
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! "Obstacle: [#{type}] #{xy.to_s} #{name}".strip
        builder.Obs({ source: ((source || (group.source if grouped?)) if AIXM.ofmx?) }.compact) do |obs|
          obs << to_uid.indent(2)
          obs.txtName(name) if name
          if AIXM.ofmx?
            obs.codeType(TYPES.key(type).to_s)
          else
            obs.txtDescrType(TYPES.key(type).to_s)
            obs.codeGroup(grouped? || clustered? ? 'Y' : 'N')
          end
          if AIXM.ofmx?
            obs.codeLgt(lighting ? 'Y' : 'N') unless lighting.nil?
            obs.codeMarking(marking ? 'Y' : 'N') unless marking.nil?
          else
            obs.codeLgt(lighting ? 'Y' : 'N')
          end
          obs.txtDescrLgt(lighting_remarks) if lighting_remarks
          obs.txtDescrMarking(marking_remarks) if marking_remarks
          obs.codeDatum('WGE')
          if xy_accuracy
            obs.valGeoAccuracy(xy_accuracy.dist.trim)
            obs.uomGeoAccuracy(xy_accuracy.unit.upcase.to_s)
          end
          obs.valElev(z.alt)
          obs.valElevAccuracy(z_accuracy.to_ft.dist.round) if z_accuracy
          obs.valHgt(height.to_ft.dist.round) if height
          if AIXM.ofmx? && !height_accurate.nil?
            obs.codeHgtAccuracy(height_accurate ? 'Y' : 'N')
          end
          obs.uomDistVer('FT')
          if AIXM.ofmx?
            obs.valRadius(radius.dist.trim)
            obs.uomRadius(radius.unit.upcase.to_s)
            if grouped?
              obs.codeGroupId(group.id)
              obs.txtGroupName(group.name) if group.name
              if linked?
                obs << linked_to.to_uid(as: :ObsUidLink).indent(2)
                obs.codeLinkType(AIXM::Feature::ObstacleGroup::LINK_TYPES.key(link_type).to_s)
              end
            end
            obs.datetimeValidWef(valid_from.xmlschema) if valid_from
            obs.datetimeValidTil(valid_until.xmlschema) if valid_until
          end
          obs.txtRmk(remarks) if remarks
        end
      end

      # Extensions used by ObstacleGroup feature
      module Grouped
        # @return [AIXM::Feature::ObstacleGroup] group this obstacle belongs to
        attr_reader :group

        # @return [AIXM::Feature::Obstacle] another obstacle this one is linked to
        attr_reader :linked_to

        # @return [Symbol] type of link between two obstacles
        attr_reader :link_type

        def group=(value)
          fail(ArgumentError, "invalid group") unless value.is_a?(AIXM::Feature::ObstacleGroup)
          @group = value
        end
        private :group=

        # @return [Boolean] whether obstacle is linked to another one
        def linked?
          !!linked_to
        end

        def linked_to=(value)
          fail(ArgumentError, "invalid linked to") unless value.is_a?(AIXM::Feature::Obstacle)
          @linked_to = value
        end
        private :linked_to=

        def link_type=(value)
          @link_type = AIXM::Feature::ObstacleGroup::LINK_TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid link type")
        end
        private :link_type=
      end

    end
  end
end