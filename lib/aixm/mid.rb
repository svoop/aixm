using AIXM::Refinements

module AIXM

  # Insert OFMX-compliant +mid+ value into XML.
  #
  # @example
  #   AIXM::Mid.new(xml: "...").xml_with_mid
  #
  # @see https://gitlab.com/openflightmaps/ofmx/wikis/Features#mid
  class Mid
    attr_reader :xml

    def initialize(xml:)
      @xml = xml
      @document = Nokogiri::XML(@xml)
    end

    def xml_with_mid
      uid_elements.each do |element|
        element['mid'] = element.to_s.payload_hash
      end
      @document.to_xml
    end

    private

    def uid_elements
      @document.xpath('//*[contains(local-name(), "Uid")]')
    end
  end

end
