## Main

#### Changes
* Fix 00:00 vs. 24:00 calculation for times with time zones

## 1.4.1

#### Changes
* Update upstream OFMX schema

## 1.4.0

#### Additions
* Runways include the center line from edge to edge as two `Rcp` features if
  the center line is known (bidirectional runway) or can be calculated
  (unidirectional runway with known dimensions).
* `Airspace#alternative_name` (OFMX only)
* `Helipad#geographic_bearing` (OFMX only)
* `AIXM::L` for lines with optional elevation profile
* Refinement `Numeric#to_deg`
* `AIXM::XY#bearing` and `AIXM::XY@add_distance`

#### Breaking Changes
* Up until now, `Rdn->geoLat` and `Rdn->geoLong` were set to the THR. This
  change sets them to the DTHR if any.
* `Runway::Direction#displaced_threshold=` fails when set as distance unless
  `Runway::Direction#xy` and `Runway::Direction#bearing` are known.
* `Runway::Direction#displaced_threshold` always returns coordinates.

#### Changes
* `Document#created_at` and similar accept local times and convert them to UTC
  when the XML is generated.
* Moved refinements `Float#to_dms` and `Float#to_rad` to `Numeric`

## 1.3.4

#### Additions
* `ckmid` skips XML schema validation if `-s` argument is set.

## 1.3.3

#### Changes
* Extend `ckmid` and `mkmid` to accept multiple files and globbing.

## 1.3.2

#### Changes
* Add `#pred` (aliased `#prev`) and `#succ` (alias `#next`) to both
  `AIXM::Date` and `AIXM::Day` in order to use them for iterations
* Pretty print generic features only to prevent segfaults on large documents

## 1.3.1

#### Changes
* Update certificate

## 1.3.0

#### Breaking Changes
* `Document#created_at` no longer falls back to `Document#effective_at`
* Renamed `AIXM::Date#succ` to `AIXM::Date#next`

#### Additions
* Refinement to pretty print Nokogiri XML documents
* XML comments on features (e.g. to include raw NOTAM)
* `Document#expiration_at` for OFMX
* Generic features as raw XML (e.g. extracted from another AIXM/OFMX file)
* Convenience combinator `AIXM::Schedule::DateTime`
* Shortcuts `AIXM::BEGINNING_OF_DAY` and `AIXM::END_OF_DAY`
* `AIXM::Date#next` and `AIXM::Date#-`

## 1.2.1

#### Additions
* Rounding of `AIXM::Schedule::Time`

## 1.2.0

#### Additions
* `Timesheet` to add custom schedules to `Timetable`
* `AIXM::Schedule::(Date|Day|Time)` for custom timetables
* Interface to allow most class instances as Hash keys

#### Fixes
* Fix typo in `GUESSED_UNIT_TYPES_MAP`

## 1.1.0

#### Breaking Changes
* `AIXM::Concerns::Association:Array#duplicates` now returns an array of arrays which
  group all duplicates together.
* `VOR#associate_dme` and `VOR#associate_tacan` no longer take the channel
  as argument but calculate it from the (ghost) frequency of the VOR.
* Replaced `#length`/`#width` with `#dimensions` on `Runway`, `Helipad` and `FATO`
* Renamed `AIXM::D#dist` to `AIXM::D#dim`
* Renamed `TLOF#helicopter_class` to `TLOF#performance_class`
* Renamed `#geographic_orientation` and `#magnetic_orientation` to more familiar
  `#geographic_bearing` and `#magnetic_bearing` on `Runway` and `FATO`
* Re-implementation of `AIXM::A` without precision
* Demoted `Address` to component
* Fixed typo in `Service` type `:vdf_direction_finding_service`

#### Additions
* Associations from `Service` to `Airport` and `Airspace`
* `AIXM::R` (rectangle)
* `Runway#marking`
* `ApproachLighting` on `Runway::Direction` and `FATO::Direction`
* `VASIS` on `Runway::Direction` and `FATO::Direction`
* `#meta` on every feature and component
* `Document#regions` which is added to the root element for OFMX

#### Changes
* Nested memoization of the same method is now allowed and won't reset the
  memoization cache anymore.
* Remove unit "mhz" from `Address` of type `:radio_frequency`.

## 1.0.0

#### Breaking Changes
* Move `Ase->txtLocalType` up into `AseUid` for OFMX

#### Additions
* Add rhumb line geometry

## 0.3.11

#### Breaking Changes
* Renamed default git branch to `main`
* Require Ruby 3.0
* `Address#address` requires and returns `AIXM::F` for type `:radio_frequency`

#### Changes
* Fix `Obstacle#source` for OFMX

#### Additions
* Add `f#voice?` and `AIXM.config.voice_channel_separation` to check whether a
  frequency belongs to the voice communication airband and use it to validate
  `Frequency`

## 0.3.10

#### Additions
* Proper `has_many` and `has_one` associations
* `AIXM::Concerns::Association:Array#find_by|find|duplicates` on `has_many` associations
* `AIXM.config.mid` now defines whether `mid` attributes are inserted or not
  provided the selected schema is OFMX
* `AIXM::Concerns::Memoize` module
* `AIXM::PayloadHash` class
* `mkmid` executable to insert `mid` attributes into valid OFMX file
* `ckmid` executable to check `mid` attributes in an OFMX file
* Geometries respond to `#point?`, `#circle?` and `#polygon?`
* `Layer#services`

#### Breaking Changes
* Require Ruby 2.7
* Moved `region` attribute from `Document` back to features again
* Use `Document#add_feature` instead of `Document@features#<<`
* Use `Document@features#find` instead of `Document#select_features`
* Use `Airspace#add_layer` instead of `Airspace@layers#<<`
* Use `Geometry#add_segment` instead of `Geometry#<<`
* Renamed `VerticalLimits` to `VerticalLimit`
* Moved `AIXM::Feature::Service` to `AIXM::Component::Service`
* Refinements `String#insert_payload_hash` and `Array#to_uuid` removed again
* Refinement `String#payload_hash` removed in favor of `AIXM::PayloadHash` class
* Refinements `Array#find|duplicates` removed

#### Changes
* Renamed `AIXM.config.mid_region` to `AIXM.config.region`

## 0.3.8

#### Additions
* `AIXM.config.mid_region` to insert `mid` attributes
* Refinement `String#insert_payload_hash`

#### Changes
* Fix calculation of magnetic bearing

## 0.3.7

#### Additions
* `Document#select_features`
* `Document#group_obstacles!`

## 0.3.6

#### Additions
* `FATO`
* `Helipad#helicopter_class` and `Helipad#marking`
* `AIXM::XY#seconds?` to detect possibly rounded or estimated coordinates
* `Airport#operator`
* `AIXM::W` (weight)
* `AIXM::P` (pressure)
* `Lighting` for use with runways, helipads and FATOs
* Surface details `#siwl_weight`, `#siwl_tire_pressure` and `#auw_weight`

#### Changes
* Generate `Airport#id` from region and `Airport#name`

## 0.3.5

#### Additions
* Refinement `Object#then_if`
* Airspace activity types `:aeromodelling` and `:glider_winch`
* `AIXM::XY#to_point` convenience method

#### Breaking Changes
* Renamed airspace activity type "TOWING" from `:winch_activity` to `:towing_traffic`
* Updated obstacles and obstacle groups to reflect recent changes in OFMX

## 0.3.4

#### Additions
* Address feature
* `Runway#preparation`, `Runway#condition` and `Runway#vfr_pattern`
* `Service#guessed_unit_type`
* Surface for `Runway|Helipad#surface`
* Extracted `AIXM::MIN`, `AIXM::SEC` and `AIXM::DMS_RE` to scan for coordinates
  in texts
* Refinements `Array#to_uuid` and `String#payload_hash`

#### Breaking Changes
* Require Ruby 2.6
* Renamed `AIXM::H` to `AIXM::A` (angle) and add simple arithmetics to make it
  more versatile
* `Runway|Helipad#composition` moved to `Runway|Helipad#surface`
* DMS notation `{-}{DD}DMMSS{.SS}[NESW]` now requires compulsory cardinal
  direction (N, E, S or W) at the end

#### Changes
* Service is a feature now

## 0.3.3

#### Additions
* `AIXM::H` (heading)

#### Changes
* Updated OFMX schema URI
* Added `eql?` and `hash` to `AIXM::XY|Z|D|H|F` to allow for instances of these
  classes to be used as Hash keys.

## 0.3.2

#### Additions
* Obstacle and obstacle group features
* `AIXM::D` (distance)

#### Breaking Changes
* All distances (circle geometry radius, helipad and runway length/width) must
  be `AIXM::D`.
* `AIXM::XY#distance` now returns `AIXM::D`
* Removed obsolete refinement `Float#to_km` (use `AIXM::D#to_km` instead)

## 0.3.1

#### Additions
* `AIXM::Error` base error which reveals the `subject`
* Consider single point geometries to be closed
* Calculate `DME#ghost_f` from `DME#channel`
* `Layer#location_indicator` and `Layer#activity`

#### Breaking Changes
* Renamed `Airport#code` to `Airport#id`
* Renamed `Airspace#short_name` to `Airspace#local_type`
* Moved `region` attribute from features to `Document`

#### Changes
* Be more permissive on `Airport#id` in order to accomodate generated codes
  built by concatting the `region` and `Airport#gps`.

## 0.3.0

#### Breaking Additions
* Global configuration with `AIXM.config`

#### Breaking Changes
* Switch from "AIXM with OFM extensions" to OFMX
* `to_aixm` renamed to `to_xml` again
* Removed signature `to_xml(extension)` in favor of `AIXM.schema`
* Removed `Array#to_digest`
* Removed `Document#complete?`
* Renamed Schedule to Timetable
* Timetable and remarks moved from Airspace to Layer (formerly known as class layer)

#### Additions
* Organization and Unit features
* Airport feature
* Refinement `Float#to_rad`
* Distance calculation with `AIXM::XY#distance`
* `Schedule#remarks`

## 0.2.3

#### Breaking Changes
* VOR types renamed from `:vor` to `:conventional` and `:doppler_vor` to `:doppler`
* NBR types added
* Marker types added

#### Changes
* `mid` attributes on all navigational aid features

## 0.2.2

#### Changes
* Bad error classes fixed
* Allow navigational aids without name

## 0.2.1

#### Breaking Changes
* DVOR and VORDME confusion fixed
* VOR can be associated with DME (-> VOR/DME) or TACAN (-> VORTAC) now
* `to_xml` renamed to `to_aixm` everywhere
* Removed `:other` from all value lists

#### Changes
* Schedule added to navigational aids

## 0.2.0

#### Breaking Changes
* Symbols such as `:qnh`, `:ofm` or `:mhz` are downcased now

#### Additions
* `AIXM::F` (frequency)
* Navigational aids features
* `AIXM::Z#qfe?` and friends

## 0.1.4

#### Breaking Changes
* `AIXM.z(alt: 123, code: :QNE)` is now `AIXM.z(123, :QNE)`

## 0.1.3

#### Breaking Changes
* Re-organization of classes in features and components

#### Additions
* Shortcut initializers e.g. `AIXM.airspace(...)`

## 0.1.2

#### Breaking Additions
* Class layers

#### Breaking Changes
* Use `document.features << (feature)` instead of `document << (feature)`

## 0.1.1

#### Additions
* Schedule (all but `TIMSH`)
* Refinement `Float#to_km` and `String#uptrans`
* Shortcut constants `AIXM::UNLIMITED` and `AIXM::H24`
* `Airspace#short_name`

#### Changes
* `Document#created_at` and `#effective_at` accept Time, Date, String or *nil*
* Separate `Document#valid?` from `#complete?`
* Write coordinates in DD if extension `:OFM` is set
* `Array#to_digest` returns Integer which fits in signed 32bit

## 0.1.0

#### Initial Implementation
* Require Ruby 2.5
* `AIXM::XY` (coordinates)
* `AIXM::Z` (altitude or elevation)
* AIXM-Snapshot 4.5 Document
* Airspace feature
* Vertical limits
* Geometry
  * Point
  * Arc
  * Border
  * Circle
* Shortcut constant `AIXM::GROUND`
* Refinements
