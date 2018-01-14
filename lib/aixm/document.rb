module AIXM
  class Document

    include Enumerable
    extend Forwardable
    using AIXM::Refinements

    def_delegators :@result_array, :each, :<<

    attr_reader :created_at, :effective_at

    ##
    # Define a AIXM-Snapshot document
    #
    # Options:
    # * +created_at+ - creation date (default: now)
    # * +effective_at+ - snapshot effective after date (default: now)
    def initialize(created_at: nil, effective_at: nil)
      @created_at, @effective_at = created_at, effective_at
      @result_array = []
    end

    ##
    # Array of features defined by this document
    def features
      @result_array
    end

    ##
    # Validate against the XSD and return an array of errors
    def errors
      xsd = Nokogiri::XML::Schema(File.open(AIXM::SCHEMA))
      xsd.validate(Nokogiri::XML(to_xml))
    end

    ##
    # Check whether the document is valid (extensions excluded)
    def valid?
      any? && reduce(true) { |b, f| b && f.valid? } && errors.none?
    end

    ##
    # Render AIXM
    #
    # Extensions:
    # * +:OFM+ - Open Flightmaps
    def to_xml(*extensions)
      now = Time.now.xmlschema
      meta = {
        'xmlns:xsi': 'http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd',
        version: '4.5',
        origin: "AIXM #{AIXM::VERSION} Ruby gem",
        created: @created_at&.xmlschema || now,
        effective: @effective_at&.xmlschema || now
      }
      meta[:version] += ' + OFM extensions of version 0.1' if extensions.include?(:OFM)
      builder = Builder::XmlMarkup.new(indent: 2)
      builder.instruct!
      builder.tag!('AIXM-Snapshot', meta) do |aixm_snapshot|
        aixm_snapshot << @result_array.map { |f| f.to_xml(extensions) }.join.indent(2)
      end
    end

  end
end
