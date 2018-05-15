module AIXM

  # Extension of StandardError which contains the subject of the error.
  #
  # @abstract
  class Error < StandardError
    attr_reader :subject

    def initialize(message, subject=nil)
      @subject = subject
      super message
    end
  end

  # @see AIXM::Component::Geometry
  # @see AIXM::Feature::Airspace#to_xml
  class GeometryError < Error; end

  # @see AIXM::Component::Layer
  # @see AIXM::Feature::Airspace#to_xml
  class LayerError < Error; end

end
