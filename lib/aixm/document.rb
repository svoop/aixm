module AIXM
  class Document

    include Enumerable
    extend Forwardable
    using AIXM::Refinements

    def_delegators :@result_array, :each, :<<

    def initialize(created_at: nil, effective_at: nil, extensions: [])
      @created_at, @effective_at, @extensions = created_at, effective_at, extensions
      @result_array = []
    end

    def features
      @result_array
    end

    def valid?
      any? && reduce(true) { |b, f| b && f.valid? }
    end

    def to_xml(*extensions)
      now = Time.now.xmlschema
      meta = {
        xsi: 'http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd',
        version: '4.5',
        origin: "AIXM #{AIXM::VERSION} Ruby gem",
        created: @created_at&.xmlschema || now,
        effective: @effective_at&.xmlschema || now
      }
      meta[:version] += ' + OFM extensions of version 0.1' if extensions.include?(:ofm)
      builder = Builder::XmlMarkup.new(indent: 2)
      builder.instruct!
      builder.tag!('AIXM-Snapshot', meta) do |aixm_snapshot|
        aixm_snapshot << @result_array.map { |f| f.to_xml(extensions) }.join.indent(2)
      end
    end

  end
end
