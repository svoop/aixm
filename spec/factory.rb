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

      def d
        AIXM.d(123, :m)
      end

      def f
        AIXM.f(123.35, :mhz)
      end

      def a
        AIXM.a('34L')
      end

      def w
        AIXM.w(1.5, :t)
      end

      def p
        AIXM.p(0.5, :mpa)
      end

      # Components

      def address
        AIXM.address(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          type: :radio_frequency,
          address: "123.35"
        ).tap do |address|
          address.remarks = "A/A (callsign PUJAUT)"
        end
      end

      def timetable
        AIXM.timetable(
          code: :sunrise_to_sunset
        ).tap do |timetable|
          timetable.remarks =  "timetable remarks"
        end
      end

      def vertical_limits
        AIXM.vertical_limits(
          upper_z: AIXM.z(65, :qne),
          max_z: AIXM.z(6000, :qnh),
          lower_z: AIXM.z(45, :qne),
          min_z: AIXM.z(3000, :qfe)
        )
      end

      def layer
        AIXM.layer(
          class: :C,
          location_indicator: 'XXXX',
          vertical_limits: vertical_limits
        ).tap do |layer|
          layer.activity = :aerodrome_traffic
          layer.timetable = AIXM::H24
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
            radius: AIXM.d(10, :km)
          )
        end
      end

      # Airspaces

      def polygon_airspace
        AIXM.airspace(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          id: 'PA',
          type: :danger_area,
          local_type: 'POLYGON',
          name: 'POLYGON AIRSPACE'
        ).tap do |airspace|
          airspace.layers << layer
          airspace.geometry = polygon_geometry
        end
      end

      def circle_airspace
        AIXM.airspace(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          id: 'CA',
          type: :danger_area,
          local_type: 'CIRCLE',
          name: 'CIRCLE AIRSPACE'
        ).tap do |airspace|
          airspace.layers << layer
          airspace.geometry = circle_geometry
        end
      end

      # Navigational aids

      def designated_point
        AIXM.designated_point(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          id: 'DDD',
          name: 'DESIGNATED POINT NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :vfr_reporting_point
        ).tap do |designated_point|
          designated_point.airport = airport
          designated_point.timetable = AIXM::H24
          designated_point.remarks = 'designated point navaid'
        end
      end

      def dme
        AIXM.dme(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          id: 'MMM',
          name: 'DME NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          channel: '95X'
        ).tap do |dme|
          dme.timetable = AIXM::H24
          dme.remarks = 'dme navaid'
        end
      end

      def marker
        AIXM.marker(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          id: '---',
          name: 'MARKER NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :outer
        ).tap do |marker|
          marker.timetable = AIXM::H24
          marker.remarks = 'marker navaid'
        end
      end

      def ndb
        AIXM.ndb(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          id: 'NNN',
          name: 'NDB NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :en_route,
          f: AIXM.f(555, :khz)
        ).tap do |ndb|
          ndb.timetable = AIXM::H24
          ndb.remarks = 'ndb navaid'
        end
      end

      def tacan
        AIXM.tacan(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          id: 'TTT',
          name: 'TACAN NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          channel: '29X'
        ).tap do |tacan|
          tacan.timetable = AIXM::H24
          tacan.remarks = 'tacan navaid'
        end
      end

      def vor
        AIXM.vor(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          id: 'VVV',
          name: 'VOR NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :conventional,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |vor|
          vor.timetable = AIXM::H24
          vor.remarks = 'vor navaid'
        end
      end

      def vordme
        AIXM.vor(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          id: 'VDD',
          name: 'VOR/DME NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :conventional,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |vordme|
          vordme.timetable = AIXM::H24
          vordme.remarks = 'vor/dme navaid'
          vordme.associate_dme(channel: '95X')
        end
      end

      def vortac
        AIXM.vor(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          id: 'VTT',
          name: 'VORTAC NAVAID',
          xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
          z: AIXM.z(500, :qnh),
          type: :conventional,
          f: AIXM.f(111, :mhz),
          north: :geographic
        ).tap do |vortac|
          vortac.timetable = AIXM::H24
          vortac.remarks = 'vortac navaid'
          vortac.associate_tacan(channel: '29X')
        end
      end

      # Organisation

      def organisation
        AIXM.organisation(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          name: 'FRANCE',
          type: 'S'
        ).tap do |organisation|
          organisation.id = 'LF'
          organisation.remarks = 'Oversea departments not included'
        end
      end

      # Unit

      def unit
        AIXM.unit(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          name: 'PUJAUT TWR',
          type: :aerodrome_control_tower,
          class: :icao
        ).tap do |unit|
          unit.airport = airport
          unit.remarks = 'FR only'
          unit.add_service(service)
        end
      end

      def service
        AIXM.service(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          type: :approach_control_service
        ).tap do |service|
          service.timetable = AIXM::H24
          service.remarks = "service remarks"
          service.add_frequency(frequency)
        end
      end

      def frequency
        AIXM.frequency(
          transmission_f: AIXM.f(123.35, :mhz),
          callsigns: { en: "PUJAUT CONTROL", fr: "PUJAUT CONTROLE" }
        ).tap do |frequency|
          frequency.type = :standard
          frequency.reception_f = AIXM.f(124.1, :mhz)
          frequency.timetable = AIXM::H24
          frequency.remarks = "frequency remarks"
        end
      end

      # Airport

      def airport
        AIXM.airport(
          source: 'LF|GEN|0.0 FACTORY|0|0',
          organisation: organisation,
          id: 'LFNT',
          name: 'Avignon-Pujaut',
          xy: AIXM.xy(lat: %q(43°59'46"N), long: %q(004°45'16"E))
        ).tap do |airport|
          airport.gps = "LFPUJAUT"
          airport.z = AIXM.z(146, :qnh)
          airport.declination = 1.08
          airport.transition_z = AIXM.z(10_000, :qnh)
          airport.remarks = "Restricted access"
          airport.add_runway(runway)
          airport.add_fato(fato)
          airport.add_helipad(helipad)
          airport.helipads.first.fato = airport.fatos.first   # necessary when using factories only
          airport.add_usage_limitation :permitted
          airport.add_usage_limitation(:reservation_required) do |reservation_required|
            reservation_required.add_condition { |c| c.aircraft = :glider }
            reservation_required.add_condition { |c| c.origin = :international }
            reservation_required.timetable = AIXM::H24
            reservation_required.remarks = "reservation remarks"
          end
          airport.add_address(address)
        end
      end

      def runway
        AIXM.runway(name: '16L/34R').tap do |runway|
          runway.length = AIXM.d(650, :m)
          runway.width = AIXM.d(80, :m)
          runway.surface.composition = :asphalt
          runway.surface.preparation = :paved
          runway.surface.condition = :good
          runway.surface.pcn = "59/F/A/W/T"
          runway.surface.siwl_weight = AIXM.w(1500, :kg)
          runway.surface.siwl_tire_pressure = AIXM.p(0.5, :mpa)
          runway.surface.auw_weight = AIXM.w(30, :t)
          runway.surface.remarks = "Paved shoulder on 2.5m on each side of the RWY."
          runway.status = :closed
          runway.remarks = "Markings eroded"
          runway.forth.xy = AIXM.xy(lat: %q(44°00'07.63"N), long: %q(004°45'07.81"E))
          runway.forth.z = AIXM.z(145, :qnh)
          runway.forth.displaced_threshold = AIXM.xy(lat: %q(44°00'03.54"N), long: %q(004°45'09.30"E))
          runway.forth.geographic_orientation = AIXM.a(165)
          runway.forth.vfr_pattern = :left_or_right
          runway.forth.remarks = "forth remarks"
          runway.back.xy = AIXM.xy(lat: %q(43°59'25.31"N), long: %q(004°45'23.24"E))
          runway.back.z = AIXM.z(147, :qnh)
          runway.back.displaced_threshold = AIXM.xy(lat: %q(43°59'31.84"N), long: %q(004°45'20.85"E))
          runway.back.geographic_orientation = AIXM.a(345)
          runway.back.vfr_pattern = :left
          runway.back.remarks = "back remarks"
        end
      end

      def fato
        AIXM.fato(name: 'H1').tap do |fato|
          fato.length = AIXM.d(35, :m)
          fato.width = AIXM.d(35, :m)
          fato.surface.composition = :concrete
          fato.surface.preparation = :paved
          fato.surface.condition = :fair
          fato.surface.pcn = "30/F/A/W/U"
          fato.surface.siwl_weight = AIXM.w(1500, :kg)
          fato.surface.siwl_tire_pressure = AIXM.p(0.5, :mpa)
          fato.surface.auw_weight = AIXM.w(8, :t)
          fato.surface.remarks = "Cracks near the center"
          fato.profile = "Northwest from RWY 12/30"
          fato.marking = "Dashed white lines"
          fato.status = :other
          fato.remarks = "Authorizaton by AD operator required"
          fato.add_direction(name: '35') do |direction|
            direction.geographic_orientation = AIXM.a(355)
            direction.remarks = "Avoid flight over residental area"
          end
        end
      end

      def helipad
        AIXM.helipad(
          name: 'H1',
          xy: AIXM.xy(lat: %q(43°59'56.94"N), long: %q(004°45'05.56"E))
        ).tap do |helipad|
          helipad.z = AIXM.z(141, :qnh)
          helipad.length = AIXM.d(20, :m)
          helipad.width = AIXM.d(20, :m)
          helipad.surface.composition = :concrete
          helipad.surface.preparation = :paved
          helipad.surface.condition = :fair
          helipad.surface.pcn = "30/F/A/W/U"
          helipad.surface.siwl_weight = AIXM.w(1500, :kg)
          helipad.surface.siwl_tire_pressure = AIXM.p(0.5, :mpa)
          helipad.surface.auw_weight = AIXM.w(8, :t)
          helipad.surface.remarks = "Cracks near the center"
          helipad.marking = "Continuous white lines"
          helipad.helicopter_class = 1
          helipad.status = :other
          helipad.remarks = "Authorizaton by AD operator required"
        end
      end

      # Obstacle

      def obstacle
        AIXM.obstacle(
          name: "Eiffel Tower",
          type: :tower,
          xy: AIXM.xy(lat: %q(48°51'29.7"N), long: %q(002°17'40.52"E)),
          radius: AIXM.d(88, :m),
          z: AIXM.z(1187 , :qnh)
        ).tap do |obstacle|
          obstacle.lighting = true
          obstacle.lighting_remarks = "red strobes"
          obstacle.marking = nil
          obstacle.marking_remarks = nil
          obstacle.height = AIXM.d(324, :m)
          obstacle.xy_accuracy = AIXM.d(2, :m)
          obstacle.z_accuracy = AIXM.d(1, :m)
          obstacle.height_accurate = true
          obstacle.valid_from = Time.parse('2018-01-01 12:00:00 +0100')
          obstacle.valid_until = Time.parse('2019-01-01 12:00:00 +0100')
          obstacle.remarks = "Temporary light installations (white strobes, gyro light etc)"
        end
      end

      def unlinked_obstacle_group
        AIXM.obstacle_group(
          name: "Mirmande éoliennes"
        ).tap do |obstacle_group|
          obstacle_group.xy_accuracy = AIXM.d(50, :m)
          obstacle_group.z_accuracy = AIXM.d(10, :m)
          obstacle_group.remarks = "Extension planned"
          obstacle_group.add_obstacle(
            AIXM.obstacle(
              name: "La Teissonière 1",
              type: :wind_turbine,
              xy: AIXM.xy(lat: %q(44°40'30.05"N), long: %q(004°52'21.24"E)),
              radius: AIXM.d(80, :m),
              z: AIXM.z(1764, :qnh)
            ).tap do |obstacle|
              obstacle.height = AIXM.d(80, :m)
              obstacle.height_accurate = false
            end
          )
          obstacle_group.add_obstacle(
            AIXM.obstacle(
              name: "La Teissonière 2",
              type: :wind_turbine,
              xy: AIXM.xy(lat: %q(44°40'46.08"N), long: %q(004°52'25.72"E)),
              radius: AIXM.d(80, :m),
              z: AIXM.z(1738 , :qnh)
            ).tap do |obstacle|
              obstacle.height = AIXM.d(80, :m)
              obstacle.height_accurate = false
            end
          )
        end
      end

      def linked_obstacle_group
        AIXM.obstacle_group(
          name: "Droitwich longwave antenna"
        ).tap do |obstacle_group|
          obstacle_group.xy_accuracy = AIXM.d(0, :m)
          obstacle_group.z_accuracy = AIXM.d(0, :ft)
          obstacle_group.remarks = "Destruction planned"
          obstacle_group.add_obstacle(
            AIXM.obstacle(
              name: "Droitwich LW north",
              type: :mast,
              xy: AIXM.xy(lat: %q(52°17'47.03"N), long: %q(002°06'24.31"W)),
              radius: AIXM.d(200, :m),
              z: AIXM.z(848 , :qnh)
            ).tap do |obstacle|
              obstacle.height = AIXM.d(700, :ft)
              obstacle.height_accurate = true
            end
          )
          obstacle_group.add_obstacle(
            AIXM.obstacle(
              name: "Droitwich LW north",
              type: :mast,
              xy: AIXM.xy(lat: %q(52°17'40.48"N), long: %q(002°06'20.47"W)),
              radius: AIXM.d(200, :m),
              z: AIXM.z(848 , :qnh)
            ).tap do |obstacle|
              obstacle.height = AIXM.d(700, :ft)
              obstacle.height_accurate = true
            end,
            linked_to: :previous,
            link_type: :cable
          )
        end
      end

      # Document

      def document
        AIXM.document(
          region: 'LF',
          namespace: '00000000-0000-0000-0000-000000000000',
          created_at: (time = Time.parse('2018-01-01 12:00:00 +0100')),
          effective_at: time
        ).tap do |document|
          document.features << organisation
          document.features << unit
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
          document.features << obstacle
          document.features << unlinked_obstacle_group
          document.features << linked_obstacle_group
        end
      end

    end
  end
end
