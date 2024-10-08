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

      def l
        AIXM.l.tap do |line|
          line.add_line_point(xy: AIXM.xy(lat: 1, long: 1), z: AIXM.z(1000, :qnh))
          line.add_line_point(xy: AIXM.xy(lat: 2, long: 2), z: AIXM.z(2000, :qnh))
        end
      end

      def r
        AIXM.r(AIXM.d(25, :m), AIXM.d(20, :m))
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

      def date
        AIXM.date('2002-02-20')
      end

      def yearless_date
        AIXM.date('02-20')
      end

      def day
        AIXM.day(:monday)
      end

      def special_day
        AIXM.day(:day_preceding_holiday)
      end

      def time
        AIXM.time('09:00')
      end

      def event
        AIXM.time(:sunrise)
      end

      def time_with_event
        AIXM.time('21:20', or: :sunset, plus: 15, whichever_comes: :last)
      end

      def datetime
        AIXM.datetime(date, time)
      end

      # Components

      def address
        AIXM.address(
          type: :radio_frequency,
          address: AIXM.f(123.35, :mhz)
        ).tap do |address|
          address.remarks = "A/A (callsign PUJAUT)"
        end
      end

      def lighting
        AIXM.lighting(
          position: :aiming_point
        ).tap do |lighting|
          lighting.description = "omnidirectional"
          lighting.intensity = :medium
          lighting.color = :green
          lighting.remarks = "lighting remarks"
        end
      end

      def approach_lighting
        AIXM.approach_lighting(
          type: :cat_1
        ).tap do |approach_lighting|
          approach_lighting.length = AIXM.d(1000, :m)
          approach_lighting.intensity = :high
          approach_lighting.sequenced_flash = false
          approach_lighting.flash_description = "three grouped bursts"
          approach_lighting.remarks = "on demand"
        end
      end

      def vasis
        AIXM.vasis.tap do |vasis|
          vasis.type = :precision_api
          vasis.position = :left_and_right
          vasis.boxes = 2
          vasis.portable = false
          vasis.slope_angle = AIXM.a(5.7)
          vasis.meht = AIXM.z(100, :qfe)
        end
      end

      def timetable
        AIXM.timetable(
          code: :sunrise_to_sunset
        ).tap do |timetable|
          timetable.remarks = "timetable remarks"
        end
      end

      def timetable_with_timesheet
        AIXM.timetable.add_timesheet(timesheet)
      end

      def timesheet
        AIXM.timesheet(
          adjust_to_dst: true,
          dates: (AIXM.date('2022-03-01')..AIXM.date('2022-03-22')),
          days: (AIXM.day(:tuesday)..AIXM.day(:thursday))
        ).tap do |timesheet|
          timesheet.times = (time..time_with_event)
        end
      end

      def vertical_limit
        AIXM.vertical_limit(
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
          vertical_limit: vertical_limit
        ).tap do |layer|
          layer.activity = :aerodrome_traffic
          layer.timetable = AIXM::H24
          layer.selective = true
          layer.remarks = 'airspace layer'
          layer.add_service(unit.services.first)
        end
      end

      def polygon_geometry
        AIXM.geometry(
          AIXM.arc(
            xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
            center_xy: AIXM.xy(lat: %q(47°54'15"N), long: %q(007°33'48"E)),
            clockwise: true
          ),
          AIXM.border(
            xy: AIXM.xy(lat: %q(47°56'37"N), long: %q(007°35'45"E)),
            name: 'FRANCE_GERMANY'
          ),
          AIXM.point(
            xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E))
          )
        )
      end

      def circle_geometry
        AIXM.geometry(
          AIXM.circle(
            center_xy: AIXM.xy(lat: %q(47°35'00"N), long: %q(004°53'00"E)),
            radius: AIXM.d(10, :km)
          )
        )
      end

      def point_geometry
        AIXM.geometry(
          AIXM.point(
            xy: AIXM.xy(lat: %q(47°35'00"N), long: %q(004°53'00"E))
          )
        )
      end

      # Airspaces

      def polygon_airspace
        AIXM.airspace(
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
          id: 'PA',
          type: :danger_area,
          local_type: 'POLYGON',
          name: 'POLYGON AIRSPACE'
        ).tap do |airspace|
          airspace.alternative_name = 'POLY AS'
          airspace.add_layer(layer)
          airspace.geometry = polygon_geometry
        end
      end

      def circle_airspace
        AIXM.airspace(
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
          id: 'CA',
          type: :danger_area,
          local_type: 'CIRCLE',
          name: 'CIRCLE AIRSPACE'
        ).tap do |airspace|
          airspace.alternative_name = 'CIR AS'
          airspace.add_layer(layer)
          airspace.geometry = circle_geometry
        end
      end

      # Navigational aids

      def designated_point
        AIXM.designated_point(
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
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
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
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
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
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
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
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
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
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
          source: "LF|GEN|0.0 FACTORY|0|0",
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
          vor.timetable = AIXM::H24
          vor.remarks = 'vor navaid'
        end
      end

      def vordme
        AIXM.vor(
          source: "LF|GEN|0.0 FACTORY|0|0",
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
          vordme.timetable = AIXM::H24
          vordme.remarks = 'vor/dme navaid'
          vordme.associate_dme
        end
      end

      def vortac
        AIXM.vor(
          source: "LF|GEN|0.0 FACTORY|0|0",
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
          vortac.timetable = AIXM::H24
          vortac.remarks = 'vortac navaid'
          vortac.associate_tacan
        end
      end

      # Organisation

      def organisation
        AIXM.organisation(
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
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
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
          organisation: organisation,
          name: 'PUJAUT',
          type: :aerodrome_control_tower,
          class: :icao
        ).tap do |unit|
          unit.remarks = 'FR only'
          unit.add_service(service)
        end
      end

      def service
        AIXM.service(
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
          frequency.timetable = timetable_with_timesheet
          frequency.remarks = "frequency remarks"
        end
      end

      # Airport

      def airport
        AIXM.airport(
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
          organisation: organisation,
          id: 'LFNT',
          name: 'Avignon-Pujaut',
          xy: AIXM.xy(lat: %q(43°59'46"N), long: %q(004°45'16"E))
        ).tap do |airport|
          airport.gps = "LFPUJAUT"
          airport.z = AIXM.z(146, :qnh)
          airport.declination = 1.08
          airport.transition_z = AIXM.z(10_000, :qnh)
          airport.operator = "Municipality of Pujaut"
          airport.remarks = "Restricted access"
          airport.add_runway(runway)
          airport.add_fato(fato)
          airport.add_helipad(helipad)
          airport.helipads.first.fato = airport.fatos.first   # necessary when using factories only
          airport.add_usage_limitation(type: :permitted)
          airport.add_usage_limitation(type: :reservation_required) do |reservation_required|
            reservation_required.add_condition do |condition|
              condition.aircraft = :glider
            end
            reservation_required.add_condition do |condition|
              condition.origin = :international
            end
            reservation_required.timetable = AIXM::H24
            reservation_required.remarks = "reservation remarks"
          end
          airport.add_unit(unit)
          airport.add_service(unit.services.first)
          airport.add_address(address)
        end
      end

      def runway
        AIXM.runway(name: '16L/34R').tap do |runway|
          runway.dimensions = AIXM.r(AIXM.d(650, :m), AIXM.d(80, :m))
          runway.surface.composition = :asphalt
          runway.surface.preparation = :paved
          runway.surface.condition = :good
          runway.surface.pcn = "59/F/A/W/T"
          runway.surface.siwl_weight = AIXM.w(1500, :kg)
          runway.surface.siwl_tire_pressure = AIXM.p(0.5, :mpa)
          runway.surface.auw_weight = AIXM.w(30, :t)
          runway.surface.remarks = "Paved shoulder on 2.5m on each side of the RWY."
          runway.marking = "Standard marking"
          runway.status = :closed
          runway.remarks = "Markings eroded"
          runway.forth.xy = AIXM.xy(lat: %q(43°59'54.71"N), long: %q(004°45'28.35"E))
          runway.forth.z = AIXM.z(144, :qnh)
          runway.forth.touch_down_zone_z = AIXM.z(145, :qnh)
          runway.forth.displaced_threshold_xy = AIXM.xy(lat: %q(43°59'48.47"N), long: %q(004°45'30.62"E))
          runway.forth.vasis = vasis
          runway.forth.geographic_bearing = AIXM.a(165.378987)
          runway.forth.vfr_pattern = :left_or_right
          runway.forth.remarks = "forth remarks"
          runway.forth.add_lighting(lighting)
          runway.forth.add_approach_lighting(approach_lighting)
          runway.back.xy = AIXM.xy(lat: %q(43°59'34.33"N), long: %q(004°45'35.74"E))
          runway.back.z = AIXM.z(148, :qnh)
          runway.back.touch_down_zone_z = AIXM.z(147, :qnh)
          runway.back.displaced_threshold_xy = AIXM.xy(lat: %q(43°59'40.88"N), long: %q(004°45'33.37"E))
          runway.back.vasis = vasis
          runway.back.geographic_bearing = AIXM.a(345.378987)
          runway.back.vfr_pattern = :left
          runway.back.remarks = "back remarks"
          runway.back.add_lighting(lighting)
          runway.back.add_approach_lighting(approach_lighting)
        end
      end

      def fato
        AIXM.fato(name: 'H1').tap do |fato|
          fato.dimensions = AIXM.r(AIXM.d(35, :m))
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
            direction.geographic_bearing = AIXM.a(355)
            direction.vasis = vasis
            direction.remarks = "Avoid flight over residental area"
            direction.add_lighting(lighting)
            direction.add_approach_lighting(approach_lighting)
          end
        end
      end

      def helipad
        AIXM.helipad(
          name: 'H1',
          xy: AIXM.xy(lat: %q(43°59'56.94"N), long: %q(004°45'05.56"E))
        ).tap do |helipad|
          helipad.geographic_bearing = AIXM.a(38.3)
          helipad.z = AIXM.z(141, :qnh)
          helipad.dimensions = AIXM.r(AIXM.d(20, :m))
          helipad.surface.composition = :concrete
          helipad.surface.preparation = :paved
          helipad.surface.condition = :fair
          helipad.surface.pcn = "30/F/A/W/U"
          helipad.surface.siwl_weight = AIXM.w(1500, :kg)
          helipad.surface.siwl_tire_pressure = AIXM.p(0.5, :mpa)
          helipad.surface.auw_weight = AIXM.w(8, :t)
          helipad.surface.remarks = "Cracks near the center"
          helipad.marking = "Continuous white lines"
          helipad.performance_class = 1
          helipad.status = :other
          helipad.remarks = "Authorizaton by AD operator required"
          helipad.add_lighting(lighting)
        end
      end

      # Obstacle

      def obstacle
        AIXM.obstacle(
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
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
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: "LF",
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
          source: "EG|GEN|0.0 FACTORY|0|0",
          region: "EG",
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

      def generic(pretty: true)
        fragment_xml = <<~END
          <Org>
            <OrgUid>
              <txtName>EUROPE</txtName>
            </OrgUid>
            <codeType>GS</codeType>
          </Org>
        END
        AIXM.generic(
          source: "LF|GEN|0.0 FACTORY|0|0",
          region: 'LF',
          fragment: (pretty ? fragment_xml : fragment_xml.gsub(/\s/, ''))
        )
      end

      # Document

      def document
        AIXM.document(
          namespace: '00000000-0000-0000-0000-000000000000',
          sourced_at: Time.utc(2022, 4, 20),
          created_at: (time = Time.utc(2022, 4, 21)),
          effective_at: time,
          expiration_at: time + 2419199
        ).tap do |document|
          document.add_feature organisation
          document.add_feature unit
          document.add_feature airport
          document.add_feature polygon_airspace
          document.add_feature circle_airspace
          document.add_feature designated_point
          document.add_feature dme
          document.add_feature marker
          document.add_feature ndb
          document.add_feature tacan
          document.add_feature vor
          document.add_feature vordme
          document.add_feature vortac
          document.add_feature obstacle
          document.add_feature unlinked_obstacle_group
          document.add_feature linked_obstacle_group
          document.add_feature generic
        end
      end

    end
  end
end
