module AIXM
  class Factory
    class << self

      def vertical_limits
        AIXM::Vertical::Limits.new(
          upper_z: AIXM::Z.new(alt: 65, code: :QNE),
          lower_z: AIXM::Z.new(alt: 45, code: :QNE),
          max_z: AIXM::Z.new(alt: 6000, code: :QNH),
          min_z: AIXM::Z.new(alt: 3000, code: :QFE)
        )
      end

      def polygon_geometry
        AIXM::Geometry.new.tap do |geometry|
          geometry << AIXM::Horizontal::Arc.new(
            xy: AIXM::XY.new(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
            center_xy: AIXM::XY.new(lat: %q(47°54'15"N), long: %q(007°33'48"E)),
            clockwise: true
          )
          geometry << AIXM::Horizontal::Border.new(
            xy: AIXM::XY.new(lat: %q(47°56'37"N), long: %q(007°35'45"E)),
            name: 'FRANCE_GERMANY'
          )
          geometry << AIXM::Horizontal::Point.new(
            xy: AIXM::XY.new(lat: %q(47°51'33"N), long: %q(007°33'36"E))
          )
        end
      end

      def circle_geometry
        AIXM::Geometry.new.tap do |geometry|
          geometry << AIXM::Horizontal::Circle.new(
            center_xy: AIXM::XY.new(lat: %q(47°35'00"N), long: %q(004°53'00"E)), 
            radius: 10
          )
        end
      end

      def polygon_airspace
        AIXM::Feature::Airspace.new(name: 'POLYGON AIRSPACE', type: 'D').tap do |airspace|
          airspace.vertical_limits = vertical_limits
          airspace.geometry = polygon_geometry
          airspace.remarks = 'polygon airspace'
        end
      end

      def circle_airspace
        AIXM::Feature::Airspace.new(name: 'CIRCLE AIRSPACE', type: 'D').tap do |airspace|
          airspace.vertical_limits = vertical_limits
          airspace.geometry = circle_geometry
          airspace.remarks = 'circle airspace'
        end
      end

      def document
        time = Time.parse('2018-01-18 12:00:00 +0100')
        AIXM::Document.new(created_at: time, effective_at: time).tap do |document|
          document << AIXM::Factory.polygon_airspace
          document << AIXM::Factory.circle_airspace
        end
      end

    end
  end
end
