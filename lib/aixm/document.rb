using AIXM::Refinements

module AIXM
  class Document
    NAMESPACE_PATTERN = /\A[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}\z/

    attr_reader :namespace, :created_at, :effective_at
    attr_accessor :features

    ##
    # Define a AIXM-Snapshot document
    #
    # Arguments:
    # * +namespace+ - UUID to namespace the data in this document
    # * +created_at+ - creation date and time (default: +effective_at+ or now)
    # * +effective_at+ - effective after date and time (default: +created_at+
    #                    or now)
    def initialize(namespace: nil, created_at: nil, effective_at: nil)
      self.namespace, self.created_at, self.effective_at = namespace, created_at, effective_at
      @features = []
    end

    def inspect
      %Q(#<#{self.class} created_at=#{created_at.inspect}>)
    end

    ##
    # UUID to namespace the data in this document
    def namespace=(value)
      fail(ArgumentError, "invalid namespace") unless value.nil? || value.match?(NAMESPACE_PATTERN)
      @namespace = value || SecureRandom.uuid
    end

    ##
    # Creation date and time (default: +effective_at+ or now)
    def created_at=(value)
      @created_at = parse_time(value) || effective_at || Time.now
    end

    ##
    # Effective after date and time (default: +created_at+ or now)
    def effective_at=(value)
      @effective_at = parse_time(value) || created_at || Time.now
    end

    ##
    # Validate atainst the XSD and return +true+ if no errors were found
    def valid?
      errors.none?
    end

    ##
    # Validate against the XSD and return an array of errors
    def errors
      xsd = Nokogiri::XML::Schema(File.open(AIXM.schema(:xsd)))
      xsd.validate(Nokogiri::XML(to_xml)).reject do |error|
        AIXM.config.ignored_errors && error.message.match?(AIXM.config.ignored_errors)
      end
    end

    ##
    # Generate XML
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
