module AIXM
  class Base
    using AIXM::Refinements

    def format_for(*extensions)
      extensions >> :ofm ? :ofm : :aixm
    end

  end
end
