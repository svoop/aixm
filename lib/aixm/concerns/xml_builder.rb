module AIXM
  module Concerns

    # Adds the XML builder wrapped to generate a document fragment.
    module XMLBuilder
      include AIXM::Memoize

      # Build a XML document fragment.
      #
      # @yield [Nokogiri::XML::Builder]
      # @return [Nokogiri::XML::DocumentFragment]
      def build_fragment
        Nokogiri::XML::DocumentFragment.parse('').tap do |document|
          Nokogiri::XML::Builder.with(document) do |fragment|
            yield fragment
          end
          document.elements.each { _1.add_next_sibling("\n") }   # add newline between tags on top level
        end
      end

      # @return [Nokogiri::XML::DocumentFragment] UID fragment
      def to_uid(...)
        build_fragment { add_uid_to(_1, ...) }
      end
      memoize :to_uid

      # @return [String] AIXM or OFMX fragment
      def to_xml(...)
        build_fragment { add_to(_1, ...) }.to_xml.strip.concat("\n")
      end

    end
  end
end
