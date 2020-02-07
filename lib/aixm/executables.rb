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
          o.on('-A', '--about', 'show author/license information and exit') { AIXM::Executables.about }
          o.on('-V', '--version', 'show version and exit') { AIXM::Executables.version }
        end.parse!
        @infile = ARGV.shift
      end

      def run
        fail 'cannot read file' unless @infile && File.readable?(@infile)
        fail 'file ist not OFMX' unless @infile.match?(/\.ofmx$/)
        AIXM.ofmx!
        document = File.open(@infile) { Nokogiri::XML(_1) }
        AIXM::PayloadHash::Mid.new(document).insert_mid
        errors = Nokogiri::XML::Schema(File.open(AIXM.schema(:xsd))).validate(document)
        case
        when errors.any? && !@options[:force]
          puts errors
          fail "OFMX file is not schema valid"
        when @options[:in_place]
          File.write(@infile, document.to_xml)
        else
          puts document.to_xml
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

    class Ckmid
      def initialize(**options)
        OptionParser.new do |o|
          o.banner = <<~END
            Check mid attributes of an OFMX file.
            Usage: #{File.basename($0)} infile.ofmx
          END
          o.on('-A', '--about', 'show author/license information and exit') { AIXM::Executables.about }
          o.on('-V', '--version', 'show version and exit') { AIXM::Executables.version }
        end.parse!
        @infile = ARGV.shift
      end

      def run
        fail 'cannot read file' unless @infile && File.readable?(@infile)
        fail 'file ist not OFMX' unless @infile.match?(/\.ofmx$/)
        AIXM.ofmx!
        document = File.open(@infile) { Nokogiri::XML(_1) }
        errors = Nokogiri::XML::Schema(File.open(AIXM.schema(:xsd))).validate(document)
        errors += AIXM::PayloadHash::Mid.new(document).check_mid
        if errors.any?
          puts errors
          fail "OFMX file has errors"
        end
      rescue => error
        puts "ERROR: #{error.message}"
        exit 1
      end
    end

    def self.about
      puts 'Written by Sven Schwyn (bitcetera.com) and distributed under MIT license.'
      exit
    end

    def self.version
      puts AIXM::VERSION
      exit
    end

  end
end
