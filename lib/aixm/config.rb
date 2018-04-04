module AIXM

  SCHEMAS = {
    aixm: {
      version: '4.5',
      namespace: 'http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd',
      xsd: Pathname(__dir__).join('..', '..', 'schemas', 'aixm', '4.5', 'AIXM-Snapshot.xsd'),
      root: 'AIXM-Snapshot'
    },
    ofmx: {
      version: '0',
      namespace: 'http://openflightmaps.org/schema/0/OFMX-Snapshot.xsd',
      xsd: Pathname(__dir__).join('..', '..', 'schemas', 'ofmx', '0', 'OFMX-Snapshot.xsd'),
      root: 'OFMX-Snapshot'
    }
  }.freeze

  class << self

    ##
    # Access the configuration (e.g. +AIXM.config.schema+)
    def config
      @@config
    end

    ##
    # Currently active schema
    #
    # To get the schema identifyer:
    #   AIXM.schema   # => :aixm
    #
    # To get schema details:
    #   AIXM.schema(:version)   # => '4.5'
    #   AIXM.schema(:root)      # => 'AIXM-Snapshot'
    def schema(key = nil)
      key ? SCHEMAS.dig(@@config.schema, key) : @@config.schema
    end

    ##
    # Shortcuts to query schema e.g. with +AIXM.ofmx?+ and to set schema e.g.
    # with +AIXM.ofmx!+
    SCHEMAS.each_key do |schema|
      define_method("#{schema}!") { @@config.schema = schema }
      define_method("#{schema}?") { @@config.schema == schema }
    end

    private

    ##
    # Default configuration
    def initialize_config
      @@config = OpenStruct.new(
        schema: :aixm,
        ignored_errors: %r(OrgUid)
      )
    end

  end
end

AIXM.send(:initialize_config)
