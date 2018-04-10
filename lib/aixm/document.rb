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
  #   )
  #   document.features << AIXM::Feature
  #
  # @see https://github.com/openflightmaps/ofmx/wiki/Snapshot
  class Document
    NAMESPACE_PATTERN = /\A[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}\z/.freeze

    # @return [String] UUID to namespace the data contained in this document
    attr_reader :namespace

    # @return [Time] creation date and time (default: +effective_at+ or now)
    attr_reader :created_at

    # @return [Time] effective after date and time (default: +created_at+ or now)
    attr_reader :effective_at

    # @return [Array<AIXM::Feature>] airspaces, airports and other features
    attr_accessor :features

    def initialize(namespace: nil, created_at: nil, effective_at: nil)
      self.namespace, self.created_at, self.effective_at = namespace, created_at, effective_at
      @features = []
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} created_at=#{created_at.inspect}>)
    end

    def namespace=(value)
      fail(ArgumentError, "invalid namespace") unless value.nil? || value.match?(NAMESPACE_PATTERN)
      @namespace = value || SecureRandom.uuid
    end

    def created_at=(value)
      @created_at = parse_time(value) || effective_at || Time.now
    end

    def effective_at=(value)
      @effective_at = parse_time(value) || created_at || Time.now
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

    private

    def parse_time(value)
      case value
        when String then Time.parse(value)
        when Date then value.to_time
        when Time then value
        when nil then nil
        else fail(ArgumentError, "invalid date or time")
      end
    end

  end
end
