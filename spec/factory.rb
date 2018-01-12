module AIXM
  class Factory
    class << self

      def geometry
        AIXM::Geometry.new.tap do |geometry|
          geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
          geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 22, long: 33))
          geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 33, long: 44))
          geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
        end
      end

      def airspace
        AIXM::Feature::Airspace.new(name: 'foobar', type: 'D').tap do |airspace|
          airspace.vertical_limits = AIXM::Vertical::Limits.new(
            upper_z: AIXM::Z.new(alt: 65, code: :QNE),
            lower_z: AIXM::Z.new(alt: 45, code: :QNE),
            max_z: AIXM::Z.new(alt: 6000, code: :QNH),
            min_z: AIXM::Z.new(alt: 3000, code: :QFE)
          )
          airspace.geometry = geometry
          airspace.remarks = 'airborn pink elephants'
        end
      end

    end
  end
end
