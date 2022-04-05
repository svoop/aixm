using AIXM::Refinements

module AIXM

  # Calculate OFMX-compliant payload hashes.
  #
  # @example with XML fragment string
  #   xml = '<xml><a></a></xml>'
  #   AIXM::PayloadHash.new(xml).to_uuid
  #
  # @example with Nokogiri fragment
  #   document = File.open("file.xml") { Nokogiri::XML(_1) }
  #   AIXM::PayloadHash.new(document).to_uuid
  #
  # @see https://gitlab.com/openflightmaps/ofmx/wikis/Features#mid
  class PayloadHash
    IGNORED_ATTRIBUTES = %w(mid source).freeze

    # @param fragment [Nokogiri::XML::DocumentFragment, Nokogiri::XML::Element,
    #   String] XML fragment
    def initialize(fragment)
      @fragment = case fragment
        when Nokogiri::XML::DocumentFragment then fragment
        when Nokogiri::XML::Element, String then Nokogiri::XML.fragment(fragment)
        else fail ArgumentError
      end
    end

    # @return [String] UUIDv3
    def to_uuid
      uuid_for payload_array
    end

    private

    def payload_array
      @fragment.css('*').each_with_object([]) do |element, array|
        array << element.name.sub(/\A(\w+Uid)\w+/, '\1')   # remove name extension
        element.attributes.sort.each do |name, attribute|
          array.push(name, attribute.value) unless IGNORED_ATTRIBUTES.include? name
        end
        array << element.child.text if element.children.one? && element.child.text?
        array << '' if element.children.none?
      end
    end

    def uuid_for(array)
      ::Digest::MD5.hexdigest(array.flatten.map(&:to_s).join('|'.freeze)).unpack("a8a4a4a4a12").join('-'.freeze)
    end

    # Insert OFMX-compliant payload hashes as mid attributes into an XML
    # document.
    #
    # Keep in mind: If you pass a Nokogiri::XML::Document, the mid attributes
    # are added into this document. In order to leave the original document
    # untouched, you have to `dup` it.
    #
    # @example with XML string
    #   string = '<OFMX-Snapshot><Ahp><AhpUid></AhpUid></Ahp></OFMX-Snapshot>'
    #   converter = AIXM::PayloadHash::Mid.new(string)
    #   converter.insert_mid.to_xml   # returns XML as String
    #
    # @example with Nokogiri document
    #   document = File.open("file.ofmx") { Nokogiri::XML(_1) }
    #   converter = AIXM::PayloadHash::Mid.new(document)
    #   converter.insert_mid.to_xml   # returns XML as String
    #   document.to_xml               # returns XML as String as well
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Features#mid
    class Mid

      # @param document [Nokogiri::XML::Document, String] XML document
      def initialize(document)
        @document = case document
          when Nokogiri::XML::Document then document
          when String then Nokogiri::XML(document)
          else fail ArgumentError
        end
      end

      # Insert or update mid attributes on all *Uid elements
      #
      # @return [self]
      def insert_mid
        uid_elements.each do |element|
          element['mid'] = AIXM::PayloadHash.new(element).to_uuid
        end
        self
      end

      # Check mid attributes on all *Uid elements
      #
      # @return [Array<String>] array of errors found
      def check_mid
        uid_elements.each_with_object([]) do |element, errors|
          unless element['mid'] == (uuid = AIXM::PayloadHash.new(element).to_uuid)
            errors << "#{element.line}: ERROR: Element '#{element.name}': mid should be #{uuid}"
          end
        end
      end

      # @return [String] XML document as XML string
      def to_xml
        @document.to_xml
      end

      private

      def uid_elements
        @document.xpath('//*[contains(local-name(), "Uid")]')
      end
    end
  end

end
