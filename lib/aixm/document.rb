module AIXM
  class Document
    using AIXM::Refinements

    IGNORE_ERROR_PATTERN = %r(OrgUid)

    attr_reader :created_at, :effective_at
    attr_accessor :features

    ##
    # Define a AIXM-Snapshot document
    #
    # Options:
    # * +created_at+ - creation date and time (default: now)
    # * +effective_at+ - snapshot effective after date and time (default: now)
    def initialize(created_at: nil, effective_at: nil)
      @created_at, @effective_at = parse_time(created_at), parse_time(effective_at)
      @features = []
    end

    ##
    # Check whether the document is complete (extensions excluded)
    def complete?
      features.any? && features.none? { |f| f.respond_to?(:complete?) && !f.complete? }
    end

    ##
    # Validate atainst the XSD and return +true+ if no errors were found
    def valid?
      errors.none?
    end

    ##
    # Validate against the XSD and return an array of errors
    def errors
      xsd = Nokogiri::XML::Schema(File.open(AIXM::SCHEMA))
      xsd.validate(Nokogiri::XML(to_xml)).reject do |error|
        error.message =~ IGNORE_ERROR_PATTERN
      end
    end

    ##
    # Render AIXM
    #
    # Extensions:
    # * +:ofm+ - Open Flightmaps
    def to_xml(*extensions)
      now = Time.now.xmlschema
      meta = {
        'xmlns:xsi': 'http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd',
        version: '4.5',
        origin: "AIXM #{AIXM::VERSION} Ruby gem",
        created: @created_at&.xmlschema || now,
        effective: @effective_at&.xmlschema || now
      }
      meta[:version] += ' + OFM extensions of version 0.1' if extensions >> :ofm
      builder = Builder::XmlMarkup.new(indent: 2)
      builder.instruct!
      builder.tag!('AIXM-Snapshot', meta) do |aixm_snapshot|
        aixm_snapshot << features.map { |f| f.to_xml(*extensions) }.join.indent(2)
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
