module AIXM

  # @abstract
  class Component
    include AIXM::Concerns::XMLBuilder
    include AIXM::Concerns::HashEquality

    # Freely usable e.g. to find_by foreign keys.
    #
    # @return [Object]
    attr_accessor :meta
  end

end
