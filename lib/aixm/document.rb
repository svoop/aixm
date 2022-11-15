using AIXM::Refinements

module AIXM

  # The AIXM-Snapshot or OFMX-Snapshot document is the root container for
  # aeronautical information such as airports or airspaces.
  #
  # ===Cheat Sheet in Pseudo Code:
  #   document = AIXM.document(
  #     namespace: String (UUID)
  #     created_at: Time or Date or String
  #     effective_at: Time or Date or String
  #     expiration_at: Time or Date or String or nil
  #   )
  #   document.add_feature(AIXM::Feature)
  #
  # @see https://gitlab.com/openflightmaps/ofmx/wikis/Snapshot
  class Document
    include AIXM::Concerns::Association

    NAMESPACE_RE = /\A[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}\z/.freeze

    # @!method features
    #   @return [Array<AIXM::Feature>] features (e.g. airport or airspace) present
    #     in this document
    #
    # @!method add_feature(feature)
    #   @param feature [AIXM::Feature]
    #   @return [self]
    has_many :features, accept: ['AIXM::Feature']

    # UUID to namespace the data contained in this document
    #
    # @overload namespace
    #   @return [String]
    # @overload namespace=(value)
    #   @param value [String]
    attr_reader :namespace

    # Creation date and UTC time
    #
    # @overload created_at
    #   @return [Time]
    # @overload created_at=(value)
    #   @param value [Time] default: {#effective_at} or now
    attr_reader :created_at

    # Effective after date and UTC time
    #
    # @overload effective_at
    #   @return [Time]
    # @overload effective_at=(value)
    #   @param value [Time] default: {#created_at} or now
    attr_reader :effective_at

    # Expiration after date and UTC time
    #
    # @overload expiration_at
    #   @return [Time, nil]
    # @overload expiration_at=(value)
    #   @param value [Time, nil]
    attr_reader :expiration_at

    # See the {cheat sheet}[AIXM::Document] for examples on how to create
    # instances of this class.
    def initialize(namespace: nil, created_at: nil, effective_at: nil, expiration_at: nil)
      self.namespace = namespace
      self.created_at, self.effective_at, self.expiration_at = created_at, effective_at, expiration_at
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} created_at=#{created_at.inspect}>)
    end

    def namespace=(value)
      fail(ArgumentError, "invalid namespace") unless value.nil? || value.match?(NAMESPACE_RE)
      @namespace = value || SecureRandom.uuid
    end

    def created_at=(value)
      @created_at = if time = value&.to_time
        fail(ArgumentError, "must be UTC") unless time.utc_offset.zero?
        time.round
      else
        Time.now.utc.round
      end
    end

    def effective_at=(value)
      @effective_at = if time = value&.to_time
        fail(ArgumentError, "must be UTC") unless time.utc_offset.zero?
        time.round
      else
        created_at || Time.now.utc.round
      end
    end

    def expiration_at=(value)
      @expiration_at = value&.to_time
      @expiration_at = if time = value&.to_time
        fail(ArgumentError, "must be UTC") unless time.utc_offset.zero?
        time.round
      end
    end

    # Regions used throughout this document.
    #
    # @return [Array<String>] white space separated list of region codes
    def regions
      features.map(&:region).uniq.sort
    end

    # Compare all ungrouped obstacles and create new obstacle groups whose
    # members are located within +max_distance+ pairwise.
    #
    # @note OFMX requires every obstacle, even single ones, to be part of an
    #   obstacle group which has a region assigned. For this to work, you must
    #   assure every obstacle has a region assigned when using this method.
    #
    # @param max_distance [AIXM::D] max distance between obstacle group member
    #   pairs (default: 1 NM)
    # @return [Integer] number of obstacle groups added
    def group_obstacles!(max_distance: AIXM.d(1, :nm))
      obstacles, list = features.find_by(:obstacle), {}
      while subject = obstacles.send(:shift)
        obstacles.each do |obstacle|
          if subject.xy.distance(obstacle.xy) <= max_distance
            [subject, obstacle].each { list[_1] = list[subject] || SecureRandom.uuid }
          end
        end
      end
      list.group_by(&:last).each do |_, grouped_list|
        first_obstacle = grouped_list.first.first
        obstacle_group = AIXM.obstacle_group(source: first_obstacle.source, region: first_obstacle.region)
        grouped_list.each { |o, _| obstacle_group.add_obstacle features.send(:delete, o) }
        add_feature obstacle_group
      end.count
    end

    # Validate the generated AIXM or OFMX against its XSD.
    #
    # @return [Boolean] whether valid or not
    def valid?
      errors.none?
    end

    # Validate the generated AIXM or OFMX against its XSD and return the
    # errors found.
    #
    # @return [Array<String>] validation errors
    def errors
      xsd = Nokogiri::XML::Schema(File.open(AIXM.schema(:xsd)))
      xsd.validate(Nokogiri::XML(to_xml)).reject do |error|
        AIXM.config.ignored_errors && error.message.match?(AIXM.config.ignored_errors)
      end
    end

    # @return [Nokogiri::XML::Document] Nokogiri AIXM or OFMX document
    def document
      meta = {
        'xmlns:xsi': AIXM.schema(:namespace),
        version: AIXM.schema(:version),
        origin: "rubygem aixm-#{AIXM::VERSION}",
        namespace: (namespace if AIXM.ofmx?),
        regions: (regions.join(' '.freeze) if AIXM.ofmx?),
        created: @created_at.xmlschema,
        effective: @effective_at.xmlschema,
        expiration: (@expiration_at&.xmlschema if AIXM.ofmx?)
      }.compact
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
        builder.send(AIXM.schema(:root), meta) do |root|
          root.text("\n")
          AIXM::Concerns::Memoize.method :to_uid do
            # TODO: indent is lost if added directly to the builder
            # features.each { _1.add_to(root) }
            features.each { root << _1.to_xml.indent(2) }
          end
          if AIXM.ofmx? && AIXM.config.mid
            AIXM::PayloadHash::Mid.new(builder.doc).insert_mid
          end
        end
      end.doc
    end

    # @return [String] AIXM or OFMX markup
    def to_xml
      document.to_xml
    end
  end
end
