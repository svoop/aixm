module AIXM

  SCHEMA = Pathname(__dir__).join('schemas', '4.5', 'AIXM-Snapshot.xsd').freeze
  GROUND = Z.new(alt: 0, code: :QFE).freeze

end
