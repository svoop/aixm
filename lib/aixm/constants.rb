module AIXM

  SCHEMA = Pathname(__dir__).join('schemas', '4.5', 'AIXM-Snapshot.xsd').freeze

  GROUND = AIXM::Z.new(alt: 0, code: :QFE).freeze
  UNLIMITED = AIXM::Z.new(alt: 999, code: :QNE).freeze

  H24 = AIXM::Schedule.new(code: :H24).freeze

end
