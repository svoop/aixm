module AIXM

  SCHEMA = Pathname(__dir__).join('schemas', '4.5', 'AIXM-Snapshot.xsd').freeze

  GROUND = Z.new(alt: 0, code: :QFE).freeze
  UNLIMITED = Z.new(alt: 999, code: :QNE).freeze
  H24 = Component::Schedule.new(code: :H24).freeze

  ELEMENTS = {
    document: Document,
    xy: XY,
    z: Z,
    airspace: Feature::Airspace,
    class_layer: Component::ClassLayer,
    geometry: Component::Geometry,
    schedule: Component::Schedule,
    vertical_limits: Component::VerticalLimits,
    arc: Component::Geometry::Arc,
    border: Component::Geometry::Border,
    circle: Component::Geometry::Circle,
    point: Component::Geometry::Point
  }.freeze

  ELEMENTS.each do |element, klass|
    define_singleton_method(element) do |*arguments|
      klass.new(*arguments)
    end
  end

end
