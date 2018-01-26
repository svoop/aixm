module AIXM
  class Factory
    class << self

      def xy
        AIXM.xy(lat: 10, long: 20)
      end

      def vertical_limits
        AIXM.vertical_limits(
          upper_z: AIXM.z(65, :qne),
          lower_z: AIXM.z(45, :qne),
          max_z: AIXM.z(6000, :qnh),
          min_z: AIXM.z(3000, :qfe)
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

      def polygon_airspace
        AIXM.airspace(
          name: 'POLYGON AIRSPACE',
          short_name: 'POLYGON',
          type: 'D'
        ).tap do |airspace|
          airspace.schedule = AIXM::H24
          airspace.class_layers << class_layer
          airspace.geometry = polygon_geometry
          airspace.remarks = 'polygon airspace'
        end
      end

      def circle_airspace
        AIXM.airspace(
          name: 'CIRCLE AIRSPACE',
          short_name: 'CIRCLE',
          type: 'D'
        ).tap do |airspace|
          airspace.schedule = AIXM::H24
          airspace.class_layers << class_layer
          airspace.geometry = circle_geometry
          airspace.remarks = 'circle airspace'
        end
      end

      def designated_point
        AIXM.designated_point(
          id: 'DDD',
          name: 'DESIGNATED POINT NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :ICAO
        ).tap do |designated_point|
          designated_point.schedule = AIXM::H24
          designated_point.remarks = 'designated point navaid'
        end
      end

      def dme
        AIXM.dme(
          id: 'MMM',
          name: 'DME NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          channel: '95X'
        ).tap do |dme|
          dme.schedule = AIXM::H24
          dme.remarks = 'dme navaid'
        end
      end

      def marker
        AIXM.marker(
          id: '---',
          name: 'MARKER NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh)
        ).tap do |marker|
          marker.schedule = AIXM::H24
          marker.remarks = 'marker navaid'
        end
      end

      def ndb
        AIXM.ndb(
          id: 'NNN',
          name: 'NDB NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          f: AIXM.f(555, :khz)
        ).tap do |ndb|
          ndb.schedule = AIXM::H24
          ndb.remarks = 'ndb navaid'
        end
      end

      def tacan
        AIXM.tacan(
          id: 'TTT',
          name: 'TACAN NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          channel: '29X'
        ).tap do |tacan|
          tacan.schedule = AIXM::H24
          tacan.remarks = 'tacan navaid'
        end
      end

      def vor
        AIXM.vor(
          id: 'VVV',
          name: 'VOR NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :vor,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |vor|
          vor.schedule = AIXM::H24
          vor.remarks = 'vor navaid'
        end
      end

      def dvor
        AIXM.vor(
          id: 'DVV',
          name: 'DOPPLER-VOR NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :doppler_vor,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |doppler_vor|
          doppler_vor.schedule = AIXM::H24
          doppler_vor.remarks = 'doppler-vor navaid'
        end
      end

      def vordme
        AIXM.vor(
          id: 'VDD',
          name: 'VOR/DME NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :vor,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |vordme|
          vordme.schedule = AIXM::H24
          vordme.remarks = 'vor/dme navaid'
          vordme.associate_dme(channel: '95X')
        end
      end

      def vortac
        AIXM.vor(
          id: 'VTT',
          name: 'VORTAC NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :vor,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |vortac|
          vortac.schedule = AIXM::H24
          vortac.remarks = 'vortac navaid'
          vortac.associate_tacan(channel: '29X')
        end
      end

      def document
        time = Time.parse('2018-01-18 12:00:00 +0100')
        AIXM.document(created_at: time, effective_at: time).tap do |document|
          document.features << AIXM::Factory.polygon_airspace
          document.features << AIXM::Factory.circle_airspace
          document.features << AIXM::Factory.designated_point
          document.features << AIXM::Factory.dme
          document.features << AIXM::Factory.marker
          document.features << AIXM::Factory.ndb
          document.features << AIXM::Factory.tacan
          document.features << AIXM::Factory.vor
          document.features << AIXM::Factory.dvor
          document.features << AIXM::Factory.vordme
          document.features << AIXM::Factory.vortac
        end
      end

    end
  end
end
