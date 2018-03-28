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
    # Currently active format
    #
    # To get the format identifyer:
    #   AIXM.format   # => :aixm
    #
    # To get format details:
    #   AIXM.format(:version)   # => '4.5'
    #   AIXM.format(:root)      # => 'AIXM-Snapshot'
    def format(key = nil)
      key ? FORMATS.dig(@@format, key) : @@format
    end

    ##
    # Shortcuts to query format e.g. with +AIXM.ofmx?+ and to set format e.g.
    # with +AIXM.ofmx!+
    FORMATS.each_key do |format|
      define_method("#{format}!") { @@format = format }
      define_method("#{format}?") { @@format == format }
    end
  end
end

##
# Use format +:aixm+ by default
AIXM.aixm!
