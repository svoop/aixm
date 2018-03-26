using AIXM::Refinements

module AIXM
  class Document
    IGNORE_ERROR_PATTERN = %r(OrgUid)

    attr_reader :created_at, :effective_at
    attr_accessor :features

    ##
    # Define a AIXM-Snapshot document
    #
    # Arguments:
    # * +created_at+ - creation date and time (default: now)
    # * +effective_at+ - snapshot effective after date and time (default: now)
    def initialize(created_at: nil, effective_at: nil)
      @created_at, @effective_at = parse_time(created_at), parse_time(effective_at)
      @features = []
    end

    ##
    # Validate atainst the XSD and return +true+ if no errors were found
    def valid?
      errors.none?
    end

    ##
    # Validate against the XSD and return an array of errors
    def errors
      xsd = Nokogiri::XML::Schema(File.open(AIXM.format(:schema)))
      xsd.validate(Nokogiri::XML(to_xml)).reject do |error|
        error.message =~ IGNORE_ERROR_PATTERN
      end
    end

    ##
    # Generate XML
    def to_xml
      now = Time.now.xmlschema
      meta = {
        'xmlns:xsi': AIXM.format(:namespace),
        version: AIXM.format(:version),
        origin: "rubygem aixm-#{AIXM::VERSION}",
        created: @created_at&.xmlschema || now,
        effective: @effective_at&.xmlschema || now
      }
      builder = Builder::XmlMarkup.new(indent: 2)
      builder.instruct!
      builder.tag!(AIXM.format(:root), meta) do |root|
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
        else fail ArgumentError
      end
    rescue ArgumentError
      raise(ArgumentError, "`#{value}' is not a valid date and time")
    end

  end
end
