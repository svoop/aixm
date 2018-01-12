module AIXM
  class << self

    ##
    # Write configuration e.g. in +initializer/aixm.rb+
    def setup
      yield @@config
    end

    ##
    # Read configuration e.g. as +AIXM.config.extensions+
    def config
      @@config
    end

    ##
    # Shortcuts to query active extensions e.g. as +AIXM.ofm?+
    def method_missing(method)
      @@config.extensions.include?(method[0..-2].to_sym) if method =~ /\?$/
    end

    private

    ##
    # Default configuration
    def initialize_config
      @@config = OpenStruct.new(
        extensions: AIXM::EXTENSIONS
      )
    end

  end
end

AIXM.send(:initialize_config)
