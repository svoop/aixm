module AIXM

  ELEMENTS = {
    document: Document,
    xy: XY,
    z: Z,
    f: F,
    airport: Feature::Airport,
    runway: Component::Runway,
#   helipad: Component::Helipad,
    airspace: Feature::Airspace,
    layer: Component::Layer,
    geometry: Component::Geometry,
    vertical_limits: Component::VerticalLimits,
    arc: Component::Geometry::Arc,
    border: Component::Geometry::Border,
    circle: Component::Geometry::Circle,
    point: Component::Geometry::Point,
    dme: Feature::NavigationalAid::DME,
    designated_point: Feature::NavigationalAid::DesignatedPoint,
    marker: Feature::NavigationalAid::Marker,
    tacan: Feature::NavigationalAid::TACAN,
    ndb: Feature::NavigationalAid::NDB,
    vor: Feature::NavigationalAid::VOR,
    schedule: Component::Schedule
  }.freeze

  ELEMENTS.each do |element, klass|
    define_singleton_method(element) do |*arguments|
      klass.new(*arguments)
    end
  end

  GROUND = z(0, :qfe).freeze
  UNLIMITED = z(999, :qne).freeze
  H24 = schedule(code: :H24).freeze

end
