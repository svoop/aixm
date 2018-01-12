module AIXM
  class Document

    include Enumerable
    extend Forwardable

    def_delegators :@result_array, :each, :<<

    def initialize(*features)
      @result_array = features
    end

    def features
      @result_array
    end

    def valid?
      any? && reduce(true) { |b, f| b && f.valid? }
    end

    def to_xml
      now = Time.now.xmlschema
      meta = {
        xsi: 'http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd',
        version: (AIXM.ofm? ? '4.5 + OFM extensions of version 0.1' : '4.5'),
        origin: "AIXM #{AIXM::VERSION} Ruby gem",
        created: now,
        effective: now
      }
      builder = Builder::XmlMarkup.new
      builder.instruct!
      builder.tag!('AIXM-Snapshot', meta) do |aixm_snapshot|
        aixm_snapshot << @result_array.map(&:to_xml).join
      end
    end

  end
end
