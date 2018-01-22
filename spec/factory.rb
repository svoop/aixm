module AIXM
  class Factory
    class << self

      def vertical_limits
        AIXM.vertical_limits(
          upper_z: AIXM.z(65, :QNE),
          lower_z: AIXM.z(45, :QNE),
          max_z: AIXM.z(6000, :QNH),
          min_z: AIXM.z(3000, :QFE)
        )
      end

      def class_layer
        AIXM.class_layer(
          class: :C,
          vertical_limits: vertical_limits
        )
      end

      def polygon_geometry
        AIXM.geometry.tap do |geometry|
          geometry << AIXM.arc(
            xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
            center_xy: AIXM.xy(lat: %q(47°54'15"N), long: %q(007°33'48"E)),
            clockwise: true
          )
          geometry << AIXM.border(
            xy: AIXM.xy(lat: %q(47°56'37"N), long: %q(007°35'45"E)),
            name: 'FRANCE_GERMANY'
          )
          geometry << AIXM.point(
            xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E))
          )
        end
      end

      def circle_geometry
        AIXM.geometry.tap do |geometry|
          geometry << AIXM.circle(
            center_xy: AIXM.xy(lat: %q(47°35'00"N), long: %q(004°53'00"E)),
            radius: 10
          )
        end
      end

      def polygon_airspace(short_name: 'POLYGON', schedule: :H24)
        AIXM.airspace(
          name: 'POLYGON AIRSPACE',
          short_name: short_name,
          type: 'D'
        ).tap do |airspace|
          airspace.schedule = AIXM.schedule(code: schedule) if schedule
          airspace.class_layers << class_layer
          airspace.geometry = polygon_geometry
          airspace.remarks = 'polygon airspace'
        end
      end

      def circle_airspace(short_name: 'CIRCLE', schedule: :H24)
        AIXM.airspace(
          name: 'CIRCLE AIRSPACE',
          short_name: short_name,
          type: 'D'
        ).tap do |airspace|
          airspace.schedule = AIXM.schedule(code: schedule) if schedule
          airspace.class_layers << class_layer
          airspace.geometry = circle_geometry
          airspace.remarks = 'circle airspace'
        end
      end

      def document
        time = Time.parse('2018-01-18 12:00:00 +0100')
        AIXM.document(created_at: time, effective_at: time).tap do |document|
          document.features << AIXM::Factory.polygon_airspace
          document.features << AIXM::Factory.circle_airspace
        end
      end

    end
  end
end
