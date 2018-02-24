module AIXM

  FORMATS = {
    aixm: Pathname(__dir__).join('schemas', 'aixm', '4.5', 'AIXM-Snapshot.xsd').freeze,
    ofmx: Pathname(__dir__).join('schemas', 'ofmx', '4.5-1', 'OFMX-Snapshot.xsd').freeze
  }.freeze

  class << self

    ##
    # Currently active format
    def format
      @@format
    end

    ##
    # Schema for currently active format
    def format_schema
      FORMATS[@@format]
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
