using AIXM::Refinements

module AIXM
  module Executables

    class Mkmid
      def initialize(**options)
        @options = options
        OptionParser.new do |o|
          o.banner = <<~END
            Add mid attributes to OFMX files.
            Usage: #{File.basename($0)} files
          END
          o.on('-i', '--[no-]in-place', 'overwrite file instead of dumping to STDOUT (default: false)') { @options[:in_place] = _1 }
          o.on('-f', '--[no-]force', 'ignore XML schema validation errors (default: false)') { @options[:force] = _1 }
          o.on('-A', '--about', 'show author/license information and exit') { AIXM::Executables.about }
          o.on('-V', '--version', 'show version and exit') { AIXM::Executables.version }
        end.parse!
        @files = ARGV
      end

      def run
        @files.each do |file|
          fail "cannot read #{file}" unless file && File.readable?(file)
          fail "#{file} is not OFMX" unless file.match?(/\.ofmx$/)
          AIXM.ofmx!
          document = File.open(file) { Nokogiri::XML(_1) }
          AIXM::PayloadHash::Mid.new(document).insert_mid
          errors = Nokogiri::XML::Schema(File.open(AIXM.schema(:xsd))).validate(document)
          case
          when errors.any? && !@options[:force]
            fail (["#{file} is not valid..."] + errors).join("\n")
          when @options[:in_place]
            File.write(file, document.to_xml)
          else
            puts document.to_xml
          end
        rescue => error
          puts "ERROR: #{error.message}"
          exit 1
        end
      end
    end

    class Ckmid
      def initialize(**options)
        @options = options
        OptionParser.new do |o|
          o.banner = <<~END
            Check mid attributes of OFMX files.
            Usage: #{File.basename($0)} files
          END
          o.on('-s', '--[no-]skip-validation', 'skip XML schema validation (default: false)') { @options[:skip_validation] = _1 }
          o.on('-A', '--about', 'show author/license information and exit') { AIXM::Executables.about }
          o.on('-V', '--version', 'show version and exit') { AIXM::Executables.version }
        end.parse!
        @files = ARGV
      end

      def run
        exit(
          @files.reduce(true) do |success, file|
            fail "cannot read #{file}" unless file && File.readable?(file)
            fail "#{file} is not OFMX" unless file.match?(/\.ofmx$/)
            AIXM.ofmx!
            document = File.open(file) { Nokogiri::XML(_1) }
            errors = []
            unless @options[:skip_validation]
              errors += Nokogiri::XML::Schema(File.open(AIXM.schema(:xsd))).validate(document)
            end
            errors += AIXM::PayloadHash::Mid.new(document).check_mid
            fail (["#{file} is not valid..."] + errors).join("\n") if errors.any?
            success && true
          rescue RuntimeError => error
            puts "ERROR: #{error.message}"
            false
          end
        )
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
