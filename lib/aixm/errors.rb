module AIXM

  # @see AIXM::Component::Geometry
  # @see AIXM::Feature::Airspace#to_xml
  class GeometryError < StandardError; end

  # @see AIXM::Component::Layer
  # @see AIXM::Feature::Airspace#to_xml
  class LayerError < StandardError; end

end
