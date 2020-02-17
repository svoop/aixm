## 0.3.9 (unreleased)

### Additions
* Proper `has_many` and `has_one` associations
* `AIXM::Association:Array#find` and `AIXM::Association:Array#duplicate` on
  `has_many` associations.
* `AIXM.config.mid` now defines whether `mid` attributes are inserted or not
  provided the selected schema is OFMX
* `AIXM::PayloadHash` class
* `mkmid` executable to insert `mid` attributes into valid OFMX file
* `ckmid` executable to check `mid` attributes in an OFMX file

### Breaking Changes
* Require Ruby 2.7
* Moved `region` attribute from `Document` back to features again
* Use `Document#add_feature` instead of `Document@features#<<`
* Use `Document@features#find` instead of `Document#select_features`
* Use `Airspace#add_layer` instead of `Airspace@layers#<<`
* Use `Geometry#add_segment` instead of `Geometry#<<`
* Renamed `VerticalLimits` to `VerticalLimit`
* Refinements `String#insert_payload_hash` and `Array#to_uuid` removed again
* Refinement `String#payload_hash` removed in favor of `AIXM::PayloadHash` class

### Changes
* Renamed `AIXM.config.mid_region` to `AIXM.config.region`

## 0.3.8

#### Additions
* `AIXM.config.mid_region` to insert `mid` attributes
* Refinement `String#insert_payload_hash`

#### Changes
* Fix calculation of magnetic bearing

## 0.3.7

#### Additions
* `AIXM::Document#select_features`
* `AIXM::Document#group_obstacles!`

## 0.3.6

#### Additions
* `AIXM::Component::FATO`
* `AIXM::Component::Helipad#helicopter_class` and `AIXM::Component::Helipad#marking`
* `AIXM::XY#seconds?` to detect possibly rounded or estimated coordinates
* `AIXM::Features::Airport#operator`
* `AIXM::W` (weight)
* `AIXM::P` (pressure)
* `AIXM::Component::Lighting` for use with runways, helipads and FATOs
* Surface details `siwl_weight`, `siwl_tire_pressure` and `auw_weight`

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
* Separate `AIXM::Document#valid?` from `#complete?`
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
