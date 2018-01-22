module AIXM

  SCHEMA = Pathname(__dir__).join('schemas', '4.5', 'AIXM-Snapshot.xsd').freeze

  ELEMENTS = {
    document: Document,
    xy: XY,
    z: Z,
    f: F,
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

  GROUND = z(0, :QFE).freeze
  UNLIMITED = z(999, :QNE).freeze
  H24 = schedule(code: :H24).freeze

end
