using AIXM::Refinements

module AIXM
  module Executables

    class Mkmid
      def initialize(**options)
        @options = options
        OptionParser.new do |o|
          o.banner = <<~END
            Add mid attributes to a schema valid OFMX file.
            Usage: #{File.basename($0)} infile.ofmx
          END
          o.on('-i', '--[no-]in-place', 'overwrite file instead of dumping to STDOUT (default: false)') { |v| @options[:in_place] = v }
          o.on('-f', '--[no-]force', 'ignore XML schema validation errors (default: false)') { |v| @options[:force] = v }
          o.on('-A', '--about', 'show author/license information and exit') { about }
          o.on('-V', '--version', 'show version and exit') { version }
        end.parse!
        @infile = ARGV.shift
        fail OptionParser::InvalidOption.new('cannot read file') unless File.readable?(@infile)
        fail OptionParser::InvalidOption.new('file ist not OFMX') unless @infile.match?(/\.ofmx$/)
      end

      def run
        AIXM.ofmx!
        xml = AIXM::Mid.new(xml: File.open(@infile)).xml_with_mid
        errors = Nokogiri::XML::Schema(File.open(AIXM.schema(:xsd))).validate(Nokogiri::XML(xml))
        case
        when errors.any? && !@options[:force]
          puts errors
          fail "OFMX file is not schema valid"
        when @options[:in_place]
          File.write(@infile, xml)
        else
          puts xml
        end
      rescue => error
        puts "ERROR: #{error.message}"
        exit 1
      end

      private

      def about
        puts 'Written by Sven Schwyn (bitcetera.com) and distributed under MIT license.'
        exit
      end

      def version
        puts AIXM::VERSION
        exit
      end
    end

  end
end
