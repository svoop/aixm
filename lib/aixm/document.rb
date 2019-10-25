using AIXM::Refinements

module AIXM

  # The AIXM-Snapshot or OFMX-Snapshot document is the root container for
  # aeronautical information such as airports or airspaces.
  #
  # ===Cheat Sheet in Pseudo Code:
  #   document = AIXM.document(
  #     region: String
  #     namespace: String (UUID)
  #     created_at: Time or Date or String
  #     effective_at: Time or Date or String
  #   )
  #   document.features << AIXM::Feature
  #
  # @see https://github.com/openflightmaps/ofmx/wiki/Snapshot
  class Document
    REGION_RE = /\A[A-Z]{2}\z/.freeze

    NAMESPACE_RE = /\A[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}\z/.freeze

    # @return [String] OFMX region all features in this document belong to
    attr_reader :region

    # @return [String] UUID to namespace the data contained in this document
    attr_reader :namespace

    # @return [Time] creation date and time (default: {#effective_at} or now)
    attr_reader :created_at

    # @return [Time] effective after date and time (default: {#created_at} or now)
    attr_reader :effective_at

    # @return [Array<AIXM::Feature>] airspaces, airports and other features
    attr_accessor :features

    def initialize(region: nil, namespace: nil, created_at: nil, effective_at: nil)
      self.region, self.namespace, self.created_at, self.effective_at = region, namespace, created_at, effective_at
      @features = []
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} created_at=#{created_at.inspect}>)
    end

    def region=(value)
      fail(ArgumentError, "invalid region") unless value.nil? || value&.upcase&.match?(REGION_RE)
      @region = value&.upcase
    end

    def namespace=(value)
      fail(ArgumentError, "invalid namespace") unless value.nil? || value.match?(NAMESPACE_RE)
      @namespace = value || SecureRandom.uuid
    end

    def created_at=(value)
      @created_at = value&.to_time || effective_at || Time.now
    end

    def effective_at=(value)
      @effective_at = value&.to_time || created_at || Time.now
    end

    # Search features and return those matching the given class and attribute
    # values
    #
    # @example
    #   select_features(:airport, id: "LFNT")
    #
    # @param klass [Class, Symbol] feature class like AIXM::Feature::Airport or
    #   AIXM::Feature::NavigationalAid::VOR, shorthand notations as symbols
    #   e.g. :airport or :vor as listed in AIXM::CLASSES are recognized as well
    # @param attributes [Hash] search attributes by their values
    # @return [Array<AIXM::Feature>]
    def select_features(klass, attributes={})
      if klass.is_a? Symbol
        klass = AIXM::CLASSES.fetch(klass, nil)
        fail(ArgumentError, "unknown feature shortcut") unless klass
      end
      features.select do |feature|
        if feature.is_a? klass
          attributes.reduce(true) do |memo, (attribute, value)|
            memo && feature.send(attribute) == value
          end
        end
      end
    end

    # Compare all ungrouped obstacles and create new obstacle groups whose
    # members are located within +max_distance+ pairwise.
    #
    # @param max_distance [AIXM::D] max distance between obstacle group member
    #   pairs (default: 1 NM)
    # @return [Integer] number of obstacle groups added
    def group_obstacles!(max_distance: AIXM.d(1, :nm))
      obstacles, list = select_features(:obstacle), {}
      while subject = obstacles.shift
        obstacles.each do |obstacle|
          if subject.xy.distance(obstacle.xy) <= max_distance
            [subject, obstacle].each { |o| list[o] = list[subject] || SecureRandom.uuid }
          end
        end
      end
      list.group_by(&:last).each do |_, grouped_list|
        obstacle_group = AIXM.obstacle_group(source: grouped_list.first.first.source)
        grouped_list.each { |o, _| obstacle_group.obstacles << features.delete(o) }
        features << obstacle_group
      end.count
    end

    # Validate the generated AIXM or OFMX atainst it's XSD.
    #
    # @return [Boolean] whether valid or not
    def valid?
      errors.none?
    end

    # Validate the generated AIXM or OFMX atainst it's XSD and return the
    # errors found.
    #
    # @return [Array<String>] validation errors
    def errors
      xsd = Nokogiri::XML::Schema(File.open(AIXM.schema(:xsd)))
      xsd.validate(Nokogiri::XML(to_xml)).reject do |error|
        AIXM.config.ignored_errors && error.message.match?(AIXM.config.ignored_errors)
      end
    end

    # @return [String] AIXM or OFMX markup
    def to_xml
      meta = {
        'xmlns:xsi': AIXM.schema(:namespace),
        version: AIXM.schema(:version),
        origin: "rubygem aixm-#{AIXM::VERSION}",
        region: (region if AIXM.ofmx?),
        namespace: (namespace if AIXM.ofmx?),
        created: @created_at.xmlschema,
        effective: @effective_at.xmlschema
      }.compact
      builder = Builder::XmlMarkup.new(indent: 2)
      builder.instruct!
      builder.tag!(AIXM.schema(:root), meta) do |root|
        root << features.map { |f| f.to_xml }.join.indent(2)
      end
    end

  end
end
