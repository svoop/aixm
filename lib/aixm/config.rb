module AIXM

  FORMATS = {
    aixm: {
      version: '4.5',
      namespace: 'http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd',
      schema: Pathname(__dir__).join('..', '..', 'schemas', 'aixm', '4.5', 'AIXM-Snapshot.xsd'),
      root: 'AIXM-Snapshot'
    },
    ofmx: {
      version: '0',
      namespace: 'http://openflightmaps.org/schema/0/OFMX-Snapshot.xsd',
      schema: Pathname(__dir__).join('..', '..', 'schemas', 'ofmx', '0', 'OFMX-Snapshot.xsd'),
      root: 'OFMX-Snapshot'
    }
  }.freeze

  class << self

    ##
    # Access the configuration (e.g. +AIXM.config.format+)
    def config
      @@config
    end

    ##
    # Currently active format
    #
    # To get the format identifyer:
    #   AIXM.format   # => :aixm
    #
    # To get format details:
    #   AIXM.format(:version)   # => '4.5'
    #   AIXM.format(:root)      # => 'AIXM-Snapshot'
    def format(key = nil)
      key ? FORMATS.dig(@@config.format, key) : @@config.format
    end

    ##
    # Shortcuts to query format e.g. with +AIXM.ofmx?+ and to set format e.g.
    # with +AIXM.ofmx!+
    FORMATS.each_key do |format|
      define_method("#{format}!") { @@config.format = format }
      define_method("#{format}?") { @@config.format == format }
    end

    private

    ##
    # Default configuration
    def initialize_config
      @@config = OpenStruct.new(
        format: :aixm
      )
    end

  end
end

AIXM.send(:initialize_config)
