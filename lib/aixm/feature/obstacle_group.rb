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
    #   )
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
    #   obstacle_group.id              # UUID v3 calculated from the group payload
    #
    # As soon as an obstacle is added to a group, it's extended with new the
    # following attributes:
    # * group - the group this object belongs to
    # * linked_to - obstacle this one is linked to (if any)
    # * link_type - type of link between the two obstacles (if any)
    #
    # The source set on the group is handed down to each of it's obstacles and
    # will be used there unless the individual obstacle overrides it with a
    # different source of it's own.
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Obstacle
    class ObstacleGroup < Feature
      public_class_method :new

      LINK_TYPES = {
        CABLE: :cable,
        SOLID: :solid,
        OTHER: :other
      }.freeze

      # @return [String] group name
      attr_reader :name

      # @return [Array<AIXM::Feature::Obstacle>] obstacles in this group
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

      # Add an obstacle to the group and optionally link it to another obstacle
      # from the group.
      #
      # @param obstacle [AIXM::Feature::Obstacle] obstacle instance
      # @param linked_to [Symbol, AIXM::Feature::Obstacle, nil] Either:
      #   * :previous - link to the obstacle last added to the group
      #   * AIXM::Feature::Obstacle - link to this specific obstacle
      # @param link_type [Symbol, nil] type of link (see {LINK_TYPES})
      # @return [self]
      def add_obstacle(obstacle, linked_to: nil, link_type: :other)
        obstacle.extend AIXM::Feature::Obstacle::Grouped
        obstacle.send(:group=, self)
        if linked_to && link_type
          obstacle.send(:linked_to=, linked_to == :previous ? @obstacles.last : linked_to)
          obstacle.send(:link_type=, link_type)
        end
        @obstacles << obstacle
        self
      end

      # @return [String] UUID version 3 group identifier
      def id
        ([name] + @obstacles.map { |o| o.xy.to_s }).to_uuid
      end
      alias_method :to_uid, :id   # features need "to_uid" for "==" to work

      # @return [String] AIXM or OFMX markup
      def to_xml
        @obstacles.map { |o| o.to_xml }.join
      end
    end

  end
end
