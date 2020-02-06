using AIXM::Refinements

module AIXM

  # Calculate OFMX-compliant payload hashes.
  #
  # If you pass a Nokogiri::XML::DocumentFragment, it is implicitly cloned and
  # therefore the original document won't be altered.
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
    # @return [Nokogiri::XML::DocumentFragment] parsed/cloned XML fragment
    attr_reader :fragment

    # @param fragment [Nokogiri::XML::DocumentFragment, String] XML fragment
    def initialize(fragment)
      @fragment = fragment.is_a?(Nokogiri::XML::DocumentFragment) ? fragment.dup : Nokogiri::XML.fragment(fragment)
    end

    # @return [String] UUIDv3
    def to_uuid
      uuid_for payload_array
    end

    private

    def payload_array
      @fragment.
        to_s.
        gsub(%r((?:mid|source)="[^"]*"), '').   # remove existing mid and source attributes
        sub(%r(\A(<\w+Uid)\w+), '\1').   # remove Uid name extension
        scan(%r(<([\w-]+)([^>]*)>([^<]*))).each_with_object([]) do |(e, a, t), m|
          m << e << a.scan(%r(([\w-]+)="([^"]*)")).sort.flatten << t
        end.
        flatten.
        keep_if { |s| s.match?(/[^[:space:]]/m) }.
        compact
    end

    def uuid_for(array)
      ::Digest::MD5.hexdigest(array.flatten.map(&:to_s).join('|')).unpack("a8a4a4a4a12").join("-")
    end

    # Insert OFMX-compliant payload hashes as mid attributes into an XML
    # document.
    #
    # @example with XML string
    #   string = '<OFMX-Snapshot><Ahp><AhpUid></AhpUid></Ahp></OFMX-Snapshot>'
    #   converter = AIXM::PayloadHash::Mid.new(string)
    #
    # @example with Nokogiri document
    #   document = File.open("file.ofmx") { Nokogiri::XML(_1) }
    #   converter = AIXM::PayloadHash::Mid.new(document)
    #
    # @example insert mid and return XML document or XML string
    #   converter.insert_mid.document   # returns Nokogiri::XML::Document
    #   converter.insert_mid.to_xml     # returns XML as String
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Features#mid
    class Mid
      # @return [Nokogiri::XML::Document] parsed/cloned XML document
      attr_reader :document

      # @param document [Nokogiri::XML::Document, String] XML document
      def initialize(document)
        @document = document.is_a?(Nokogiri::XML::Document) ? document : Nokogiri::XML(document)
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

      # @return [Nokogiri::XML::Document] parsed/cloned XML document as string
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
