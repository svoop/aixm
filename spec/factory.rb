module AIXM
  class Factory
    class << self

      # Base

      def xy
        AIXM.xy(lat: 10, long: 20)
      end

      def z
        AIXM.z(1000, :qnh)
      end

      def f
        AIXM.f(123.35, :mhz)
      end

      # Components

      def schedule
        AIXM.schedule(
          code: :sunrise_to_sunset
        ).tap do |schedule|
          schedule.remarks =  "schedule remarks"
        end
      end

      def vertical_limits
        AIXM.vertical_limits(
          upper_z: AIXM.z(65, :qne),
          lower_z: AIXM.z(45, :qne),
          max_z: AIXM.z(6000, :qnh),
          min_z: AIXM.z(3000, :qfe)
        )
      end

      def layer
        AIXM.layer(
          class: :C,
          vertical_limits: vertical_limits
        ).tap do |layer|
          layer.schedule = AIXM::H24
          layer.selective = true
          layer.remarks = 'airspace layer'
        end
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

      # Airspaces

      def polygon_airspace
        AIXM.airspace(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          id: 'PA',
          type: 'D',
          name: 'POLYGON AIRSPACE',
          short_name: 'POLYGON'
        ).tap do |airspace|
          airspace.layers << layer
          airspace.geometry = polygon_geometry
        end
      end

      def circle_airspace
        AIXM.airspace(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          id: 'CA',
          type: 'D',
          name: 'CIRCLE AIRSPACE',
          short_name: 'CIRCLE'
        ).tap do |airspace|
          airspace.layers << layer
          airspace.geometry = circle_geometry
        end
      end

      # Navigational aids

      def designated_point
        AIXM.designated_point(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
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
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          organisation: organisation,
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
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          organisation: organisation,
          id: '---',
          name: 'MARKER NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :outer
        ).tap do |marker|
          marker.schedule = AIXM::H24
          marker.remarks = 'marker navaid'
        end
      end

      def ndb
        AIXM.ndb(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          organisation: organisation,
          id: 'NNN',
          name: 'NDB NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :en_route,
          f: AIXM.f(555, :khz)
        ).tap do |ndb|
          ndb.schedule = AIXM::H24
          ndb.remarks = 'ndb navaid'
        end
      end

      def tacan
        AIXM.tacan(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          organisation: organisation,
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
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          organisation: organisation,
          id: 'VVV',
          name: 'VOR NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :conventional,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |vor|
          vor.schedule = AIXM::H24
          vor.remarks = 'vor navaid'
        end
      end

      def vordme
        AIXM.vor(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          organisation: organisation,
          id: 'VDD',
          name: 'VOR/DME NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :conventional,
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
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          organisation: organisation,
          id: 'VTT',
          name: 'VORTAC NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :conventional,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |vortac|
          vortac.schedule = AIXM::H24
          vortac.remarks = 'vortac navaid'
          vortac.associate_tacan(channel: '29X')
        end
      end

      # Organisation

      def organisation
        AIXM.organisation(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          name: 'FRANCE',
          type: 'S'
        ).tap do |organisation|
          organisation.id = 'LF'
          organisation.remarks = 'Oversea departments not included'
        end
      end

      # Airport

      def airport
        AIXM.airport(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          region: 'LF',
          organisation: organisation,
          code: 'LFNT',
          name: 'Avignon-Pujaut',
          xy: AIXM.xy(lat: %q(43°59'46"N), long: %q(004°45'16"E))
        ).tap do |airport|
          airport.gps = "LFPUJAUT"
          airport.z = AIXM.z(146, :qnh)
          airport.declination = 1.08
          airport.transition_z = AIXM.z(10_000, :qnh)
          airport.remarks = "Restricted access"
          airport.add_runway(runway)
          airport.add_helipad(helipad)
          airport.add_usage_limitation :permitted
          airport.add_usage_limitation(:reservation_required) do |reservation_required|
            reservation_required.add_condition { |c| c.aircraft = :glider }
            reservation_required.add_condition { |c| c.origin = :international }
            reservation_required.schedule = AIXM::H24
            reservation_required.remarks = "reservation remarks"
          end
        end
      end

      def runway
        AIXM.runway(name: '16L/34R').tap do |runway|
          runway.length = 650
          runway.width = 80
          runway.composition = :graded_earth
          runway.status = :closed
          runway.remarks = "Markings eroded"
          runway.forth.xy = AIXM.xy(lat: %q(44°00'07.63"N), long: %q(004°45'07.81"E))
          runway.forth.z = AIXM.z(145, :qnh)
          runway.forth.displaced_threshold = AIXM.xy(lat: %q(44°00'03.54"N), long: %q(004°45'09.30"E))
          runway.forth.geographic_orientation = 165
          runway.forth.remarks = "forth remarks"
          runway.back.xy = AIXM.xy(lat: %q(43°59'25.31"N), long: %q(004°45'23.24"E))
          runway.forth.z = AIXM.z(147, :qnh)
          runway.back.displaced_threshold = AIXM.xy(lat: %q(43°59'31.84"N), long: %q(004°45'20.85"E))
          runway.back.geographic_orientation = 345
          runway.back.remarks = "back remarks"
        end
      end

      def helipad
        AIXM.helipad(name: 'H1').tap do |helipad|
          helipad.xy = AIXM.xy(lat: %q(43°59'56.94"N), long: %q(004°45'05.56"E))
          helipad.z = AIXM.z(141, :qnh)
          helipad.length = 20
          helipad.width = 20
          helipad.composition = :grass
          helipad.status = :other
          helipad.remarks = "Authorizaton by AD operator required"
        end
      end

      # Document

      def document
        time = Time.parse('2018-01-01 12:00:00 +0100')
        AIXM.document(
          namespace: '00000000-0000-0000-0000-000000000000',
          created_at: time,
          effective_at: time
        ).tap do |document|
          document.features << organisation
          document.features << airport
          document.features << polygon_airspace
          document.features << circle_airspace
          document.features << designated_point
          document.features << dme
          document.features << marker
          document.features << ndb
          document.features << tacan
          document.features << vor
          document.features << vordme
          document.features << vortac
        end
      end

    end
  end
end
