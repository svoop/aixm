using AIXM::Refinements

module AIXM
  class Feature

    # Groups of obstacles which consist of either linked (e.g. power line
    # towers) or unlinked (e.g. wind turbines) members.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   obstacle_group = AIXM.obstacle_group(
    #     source: String or nil        # see remarks below
    #     name: String or nil
    #   ).tap do |obstacle_group|
    #     obstacle_group.xy_accuracy = AIXM.d or nil
    #     obstacle_group.z_accuracy = AIXM.d or nil
    #     obstacle_group.remarks = String or nil
    #   end
    #   obstacle_group.add_obstacle(   # add an obstacle to the group
    #     AIXM.obstacle
    #   )
    #   obstacle_group.add_obstacle(   # add an obstacle to the group and link
    #     AIXM.obstacle,               # it to the obstacle last added to the group
    #     linked_to: :previous,
    #     link_type: LINK_TYPES
    #   )
    #   obstacle_group.add_obstacle(   # add an obstacle to the group and link
    #     AIXM.obstacle,               # it to any obstacle already in the group
    #     linked_to: AIXM.obstacle,
    #     link_type: LINK_TYPES
    #   )
    #
    # Please note: As soon as an obstacle is added to an obstacle group, the
    # +xy_accuracy+ and +z_accuracy+ of the obstacle group overwrite whatever
    # is set on the individual obstacles!
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Obstacle
    class ObstacleGroup < Feature
      public_class_method :new

      # @!method source
      #   @return [String] reference to source of the feature data
      # @!method name
      #   @return [String] obstacle group name
      # @!method xy_accuracy
      #   @return [AIXM::D, nil] margin of error for circular base center point
      # @!method z_accuracy
      #   @return [AIXM::D, nil] margin of error for top point
      %i(source name xy_accuracy z_accuracy).each do |method|
        define_method method do
          instance_variable_get(:"@#{method}") || obstacles.first&.send(method)
        end
      end

      # @return [String, nil] free text remarks
      attr_reader :remarks

      # @return [Array<AIXM::Feature::Obstacle>] obstacles in this obstacle group
      attr_reader :obstacles

      def initialize(source: nil, name: nil)
        super(source: source)
        self.name = name
        @obstacles = []
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} #{@obstacles.count} obstacle(s)>)
      end

      def name=(value)
        fail(ArgumentError, "invalid name") unless value.nil? || value.is_a?(String)
        @name = value&.uptrans
      end

      def xy_accuracy=(value)
        fail(ArgumentError, "invalid xy accuracy") unless value.nil? || value.is_a?(AIXM::D)
        @xy_accuracy = value
      end

      def z_accuracy=(value)
        fail(ArgumentError, "invalid z accuracy") unless value.nil? || value.is_a?(AIXM::D)
        @z_accuracy = value
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # Add an obstacle to the obstacle group and optionally link it to another
      # obstacle from the obstacle group.
      #
      # @param obstacle [AIXM::Feature::Obstacle] obstacle instance
      # @param linked_to [Symbol, AIXM::Feature::Obstacle, nil] Either:
      #   * :previous - link to the obstacle last added to the obstacle group
      #   * AIXM::Feature::Obstacle - link to this specific obstacle
      # @param link_type [Symbol, nil] type of link (see
      #   {AIXM::Feature::Obstacle::LINK_TYPES})
      # @return [self]
      def add_obstacle(obstacle, linked_to: nil, link_type: :other)
        obstacle.send(:obstacle_group=, self)
        if linked_to && link_type
          obstacle.send(:linked_to=, linked_to == :previous ? @obstacles.last : linked_to)
          obstacle.send(:link_type=, link_type)
        end
        @obstacles << obstacle
        self
      end

      # @return [String] UID markup
      def to_uid
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.OgrUid do |ogr_uid|
          ogr_uid.txtName(name)
          ogr_uid.geoLat(obstacles.first.xy.lat(AIXM.schema))
          ogr_uid.geoLong(obstacles.first.xy.long(AIXM.schema))
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml
        builder = Builder::XmlMarkup.new(indent: 2)
        if AIXM.ofmx?
          builder.comment! "Obstacle group: #{name}".strip
          builder.Ogr({ source: (source if AIXM.ofmx?) }.compact) do |ogr|
            ogr << to_uid.indent(2)
            ogr.codeDatum('WGE')
            if xy_accuracy
              ogr.valGeoAccuracy(xy_accuracy.dist.trim)
              ogr.uomGeoAccuracy(xy_accuracy.unit.upcase.to_s)
            end
            if z_accuracy
              ogr.valElevAccuracy(z_accuracy.to_ft.dist.round)
              ogr.uomElevAccuracy('FT')
            end
            ogr.txtRmk(remarks) if remarks
          end
        end
        obstacles.each { |o| builder << o.to_xml(delegate: false) }
        builder.target!
      end
    end

  end
end
