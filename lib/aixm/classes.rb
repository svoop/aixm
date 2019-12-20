module AIXM

  # Manifest of shorthand names and their corresponding AIXM class names
  CLASSES = {
    document: 'AIXM::Document',
    xy: 'AIXM::XY',
    z: 'AIXM::Z',
    d: 'AIXM::D',
    f: 'AIXM::F',
    a: 'AIXM::A',
    w: 'AIXM::W',
    p: 'AIXM::P',
    address: 'AIXM::Feature::Address',
    organisation: 'AIXM::Feature::Organisation',
    unit: 'AIXM::Feature::Unit',
    service: 'AIXM::Feature::Service',
    frequency: 'AIXM::Component::Frequency',
    airport: 'AIXM::Feature::Airport',
    runway: 'AIXM::Component::Runway',
    fato: 'AIXM::Component::FATO',
    helipad: 'AIXM::Component::Helipad',
    surface: 'AIXM::Component::Surface',
    lighting: 'AIXM::Component::Lighting',
    airspace: 'AIXM::Feature::Airspace',
    layer: 'AIXM::Component::Layer',
    geometry: 'AIXM::Component::Geometry',
    vertical_limit: 'AIXM::Component::VerticalLimit',
    arc: 'AIXM::Component::Geometry::Arc',
    border: 'AIXM::Component::Geometry::Border',
    circle: 'AIXM::Component::Geometry::Circle',
    point: 'AIXM::Component::Geometry::Point',
    dme: 'AIXM::Feature::NavigationalAid::DME',
    designated_point: 'AIXM::Feature::NavigationalAid::DesignatedPoint',
    marker: 'AIXM::Feature::NavigationalAid::Marker',
    tacan: 'AIXM::Feature::NavigationalAid::TACAN',
    ndb: 'AIXM::Feature::NavigationalAid::NDB',
    vor: 'AIXM::Feature::NavigationalAid::VOR',
    obstacle: 'AIXM::Feature::Obstacle',
    obstacle_group: 'AIXM::Feature::ObstacleGroup',
    timetable: 'AIXM::Component::Timetable'
  }.freeze

end
