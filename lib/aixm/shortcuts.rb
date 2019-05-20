module AIXM

  # List of shorthand names and their corresponding AIXM classes
  CLASSES = {
    document: Document,
    xy: XY,
    z: Z,
    d: D,
    f: F,
    a: A,
    w: W,
    p: P,
    address: Feature::Address,
    organisation: Feature::Organisation,
    unit: Feature::Unit,
    service: Feature::Service,
    frequency: Component::Frequency,
    airport: Feature::Airport,
    runway: Component::Runway,
    fato: Component::FATO,
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
  }.freeze

  CLASSES.each do |element, klass|
    define_singleton_method(element) do |*arguments|
      klass.new(*arguments)
    end
  end

  # Ground level
  GROUND = z(0, :qfe).freeze

  # Max flight level used to signal "no upper limit"
  UNLIMITED = z(999, :qne).freeze

  # Timetable used to signal "always active"
  H24 = timetable(code: :H24).freeze

end
