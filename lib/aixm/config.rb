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
      namespace: 'http://schema.openflightmaps.org/0/OFMX-Snapshot.xsd',
      xsd: Pathname(__dir__).join('..', '..', 'schemas', 'ofmx', '0', 'OFMX-Snapshot.xsd'),
      root: 'OFMX-Snapshot'
    }
  }.freeze

  class << self

    # Access the configuration (e.g. +AIXM.config.schema+)
    # @return [OpenStruct] configuration struct
    def config
      @@config
    end

    # Currently active schema
    #
    # @example Get the schema identifyer
    #   AIXM.schema   # => :aixm
    #
    # @example Get schema details
    #   AIXM.schema(:version)   # => '4.5'
    #   AIXM.schema(:root)      # => 'AIXM-Snapshot'
    #
    # @param key [Symbol, nil] schema detail key (see {SCHEMAS})
    # @return [Object] schema detail value
    def schema(key = nil)
      key ? SCHEMAS.dig(@@config.schema, key) : @@config.schema
    end

    # Shortcuts to set the schema.
    #
    # @example
    #   AIXM.aixm!   # => :aixm
    #   AIXM.ofmx?   # => false
    #   AIXM.ofmx!   # => :ofmx
    #   AIXM.ofmx?   # => true
    #
    # @!method aixm!
    # @!method ofmx!
    # @return [Symbol] schema key
    SCHEMAS.each_key do |schema|
      define_method("#{schema}!") { @@config.schema = schema }
    end

    # Shortcuts to query the schema.
    #
    # @example
    #   AIXM.aixm!   # => :aixm
    #   AIXM.ofmx?   # => false
    #   AIXM.ofmx!   # => :ofmx
    #   AIXM.ofmx?   # => true
    #
    # @!method aixm?
    # @!method ofmx?
    # @return [Boolean]
    SCHEMAS.each_key do |schema|
      define_method("#{schema}?") { @@config.schema == schema }
    end

    private

    # Configuration defaults (view source for more).
    #
    # @!visibility public
    # @api private
    # @return [OpenStruct]
    def initialize_config
      @@config = OpenStruct.new(
        schema: :aixm,
        voice_channel_separation: :any,
        mid: false,
        inflector: Dry::Inflector.new
      )
    end

  end
end

AIXM.send(:initialize_config)
