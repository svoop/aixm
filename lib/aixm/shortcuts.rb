module AIXM

  {
    document: Document,
    xy: XY,
    z: Z,
    d: D,
    f: F,
    a: A,
    organisation: Feature::Organisation,
    unit: Feature::Unit,
    service: Component::Service,
    frequency: Component::Frequency,
    airport: Feature::Airport,
    runway: Component::Runway,
    helipad: Component::Helipad,
    surface: Component::Surface,
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
    obstacle: Feature::Obstacle,
    obstacle_group: Feature::ObstacleGroup,
    timetable: Component::Timetable
  }.each do |element, klass|
    define_singleton_method(element) do |*arguments|
      klass.new(*arguments)
    end
  end

  GROUND = z(0, :qfe).freeze
  UNLIMITED = z(999, :qne).freeze
  H24 = timetable(code: :H24).freeze

end
