[![Version](https://img.shields.io/gem/v/aixm.svg?style=flat)](https://rubygems.org/gems/aixm)
[![Continuous Integration](https://img.shields.io/travis/svoop/aixm/master.svg?style=flat)](https://travis-ci.org/svoop/aixm)
[![Code Climate](https://img.shields.io/codeclimate/github/svoop/aixm.svg?style=flat)](https://codeclimate.com/github/svoop/aixm)
[![Gitter](https://img.shields.io/gitter/room/svoop/aixm.svg?style=flat)](https://gitter.im/svoop/aixm)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

# AIXM

Partial implementation of the [Aeronautical Information Exchange Model (AIXM 4.5)](http://aixm.aero) and it's dialect [Open FlightMaps eXchange format (OFMX 4.5-1)](https://github.com/openflightmaps/ofmx) for Ruby.

For now, only the parts needed to automize the AIP import of [Open Flightmaps](https://openflightmaps.org) are part of this gem. Most notably, the gem is only a builder for snapshot files and does not parse them.

* [Homepage](https://github.com/svoop/aixm)
* [API](http://www.rubydoc.info/gems/aixm)
* Author: [Sven Schwyn - Bitcetera](http://www.bitcetera.com)

## Install

Add this to your `Gemfile`:

```ruby
gem aixm
```

## Usage

Here's how to build a document object, populate it with a simple feature and then render it as AIXM:

```ruby
document = AIXM.document
document.features << AIXM.designated_point(
  id: "ABIXI",
  xy: AIXM.xy(lat: %q(46°31'54.3"N), long: %q(002°19'55.2"W)),
  type: :icao
)
document.aixm!   # not really necessary since AIXM is the default format
document.to_xml
```

You can initialize all elements either traditionally or by use of shorter AIXM class methods. The following two statements are identical:

```ruby
AIXM::Feature::NavigationalAid::DesignatedPoint.new(...)
AIXM.designated_point(...)
```

## Configuration

The following configuration options are available for setting and getting:

```ruby
AIXM.config.format           # either :aixm (default) or :ofmx
AIXM.config.region           # fallback region
AIXM.config.ignored_errors   # regex of ignored XML schema errors
```

There are shortcuts to set and get the format:

```ruby
AIXM.format             # => :aixm
AIXM.aixm?              # => true
AIXM.ofmx!              # => :ofmx
AIXM.ofmx?              # => true
AIXM.format             # => :ofmx
AIXM.format(:version)   # => 0
```

## Validation

`AIXM::Document#valid?` validates the resulting AIXM or OFMX against its XML schema. If any, you find the errors in `AIXM::Document#errors`.

## Model

### Document

The document is the root container of the AIXM snapshot file to be generated. It's essentially a collection of features:

```ruby
document = AIXM.document(created_at: Time.now, effective_at: Time.now)
document.features << AIXM.airspace(...)
```

To give you an overview of the AIXM building blocks, the remainder of this guide will use pseudo code to describe the initializer arguments, writer methods etc:

```ruby
document = AIXM.document(
  namespace: UUID
  created_at: Time or Date or String
  effective_at: Time or Date or String
)
document.features << AIXM::Feature
```

Please read the [OFMX documentation](https://github.com/openflightmaps/ofmx/wiki) to get an overview of the most relevant parts of AIXM as well as differences between AIXM and OFMX!

See [the API documentation](http://www.rubydoc.info/gems/aixm) for details and [spec/factory.rb](https://github.com/svoop/aixm/blob/master/spec/factory.rb) for examples.

#### Coordinate

All of the below are equivalent:

```ruby
AIXM.xy(lat: %q(11°22'33.44"), long: %q(-111°22'33.44"))
AIXM.xy(lat: '112233.44N', long: '1112233.44W')
AIXM.xy(lat: 11.375955555555556, long: -111.37595555555555)
```

You can calculate the distance in meters between two coordinates:

```ruby
a = AIXM.xy(lat: %q(44°00'07.63"N), long: %q(004°45'07.81"E))
b = AIXM.xy(lat: %q(43°59'25.31"N), long: %q(004°45'23.24"E))
a.distance(b)   # => 1351
```

#### Altitude and Heights

Altitudes and heights exist in three different forms at the base of feet:

```ruby
AIXM.z(1000, :qfe)   # height: 1000 ft above ground
AIXM.z(2000, :qnh)   # altitude: of 2000 ft above mean sea level
AIXM.z(45, :qne)     # altitude: flight level 45
```

Some common values are available as convenience constants:

* `AIXM::GROUND` - height: 0ft above ground
* `AIXM::UNLIMITED` - altitude: FL 999

#### Frequency

```ruby
AIXM.f(123.35, :mhz)
```

### Features

#### Airspace

```ruby
airspace = AIXM.airspace(
  region: String or nil (to use +AIXM.config.region+)
  id: String
  type: String or Symbol
  name: String
  short_name: String or nil
)
airspace.geometry << AIXM.point or AIXM.arc or AIXM.border or AIXM.circle
airspace.layers << AIXM.layer
```

#### Airport

```ruby
airport = AIXM.airport(
  region: String or nil (to use +AIXM.config.region+)
  code: String
  name: String
  xy: AIXM.xy
)
airport.gps = String
airport.type = :landing_site
airport.z = AIXM.z
airport.declination = Float
airport.transition_z = AIXM.z
airport.remarks = String or nil
airport.add_runway(AIXM.runway)
airport.add_helipad(AIXM.helipad)
airport.add_usage_limitation(...) { ... }   # see below
```

##### Usage Limitation

You can add multiple usage limitations which are are either:

* `:permitted`
* `:forbidden`
* `:reservation_required` - specify in *remarks*
* `:other` - specify in *remarks*

Simple limitations apply to any traffic:

```ruby
airport.add_usage_limitation :permitted or :forbidden or
                             :reservation_required or :other
```

Or specify the traffic a limitation (e.g. `:permitted`) applies to:

```ruby
airport.add_usage_limitation(:permitted) do |permitted|
  permitted.add_condition do |condition|
    condition.aircraft = :landplane or :seaplane or :amphibian or :helicopter or
                         :gyrocopter or :tilt_wing or :short_takeoff_and_landing or
                         :glider or :hangglider or :paraglider or :ultra_light or
                         :balloon or :unmanned_drone or :other
    condition.rule = :ifr or :vfr or :ifr_and_vfr
    condition.realm = :civil or :military or :other
    condition.origin = :international or :national or :any or :other
    condition.purpose = :scheduled or :not_scheduled or :private or
                        :school_or_training or :aerial_work or :other
  end
  permitted.schedule = AIXM.schedule
  permitted.remarks = String or nil
end
```

Multiple conditions are joined with an implicit *or* whereas the specifics of a condition (aircraft, rule etc) are joined with an implicit *and*.

#### Navigational Aid

##### Designated Point

```ruby
designated_point = AIXM.designated_point(
  region: String or nil (to use +AIXM.config.region+)
  id: String
  name: String or nil
  xy: AIXM.xy
  z: AIXM.z or nil
  type: :icao or :adhp, or :coordinates
)
designated_point.remarks = String or nil
```

##### DME

```ruby
dme = AIXM.dme(
  region: String or nil (to use +AIXM.config.region+)
  id: String
  name: String
  xy: AIXM.xy
  z: AIXM.z or nil
  channel: String
)
dme.schedule = AIXM.schedule
dme.remarks = String or nil
```

##### NDB

```ruby
ndb = AIXM.ndb(
  region: String or nil (to use +AIXM.config.region+)
  id: String
  name: String
  xy: AIXM.xy
  z: AIXM.z or nil
  type: :en_route, :locator or :marine
  f: AIXM.f
)
ndb.schedule = AIXM.schedule
ndb.remarks = String or nil
```

##### Marker

WARNING: Marker are not fully implemented because they usually have to be
associated with ILS which are not yet implemented.

```ruby
marker = AIXM.marker(
  region: String or nil (to use +AIXM.config.region+)
  id: String
  name: String
  xy: AIXM.xy
  z: AIXM.z or nil
  type: :outer, :middle, :inner or :backcourse
)
marker.schedule = AIXM.schedule
marker.remarks = String or nil
```

##### TACAN

```ruby
tacan = AIXM.tacan(
  region: String or nil (to use +AIXM.config.region+)
  id: String
  name: String
  xy: AIXM.xy
  z: AIXM.z or nil
  channel: String
)
tacan.schedule = AIXM.schedule
tacan.remarks = String or nil
```

##### VOR

```ruby
vor = AIXM.vor(
  region: String or nil (to use +AIXM.config.region+)
  id: String
  name: String
  xy: AIXM.xy
  z: AIXM.z or nil  
  type: :conventional or :doppler
  f: AIXM.f
  north: :geographic or :grid or :magnetic
)
vor.schedule = AIXM.schedule
vor.remarks = String or nil
vor.associate_dme(channel: String)     # turns the VOR into a VOR/DME
vor.associate_tacan(channel: String)   # turns the VOR into a VORTAC
```

### Components

#### Layer

```ruby
layer = AIXM.layer(
  class: String or nil
  vertical_limits: AIXM.vertical_limits
)
layer.schedule = AIXM.schedule
layer.selective = true or false (default)
layer.remarks = String or nil
```

#### Geometry

```ruby
geometry = AIXM.geometry
geometry << AIXM.point or AIXM.arc or AIXM.border or AIXM.circle
```

For a geometry to be complete, it must be comprised of either:

* exactly one circle
* at least three points, arcs or borders (the last of which a point with identical coordinates as the first)

#### Point, Arc, Border and Circle

```ruby
point = AIXM.point(
  xy: AIXM.xy
)
arc = AIXM.arc(
  xy: AIXM.xy
  center_xy: AIXM.xy
  clockwise: true or false
)
border = AIXM.border(
  xy: AIXM.xy
  name: String
)
circle = AIXM.circle(
  center_xy: AIXM.xy
  radius: Numeric   # kilometers
)
```

#### Runway

```ruby
runway = AIXM.runway(
  name: String
)
runway.length = Integer   # meters
runway.width = Integer    # meters
runway.composition = :asphalt or :bitumen or :concrete or :gravel or
                     :macadam or :sand or :graded_earth or :grass or :water or
                     :other
runway.remarks = String or nil
```

A runway has one or to directions accessible as `runway.forth` (mandatory) and
`runway.back` (optional). Both have identical properties:

```ruby
runway.forth.name = String   # preset based on the runway name
runway.forth.geographic_orientation = Integer   # degrees
runway.forth.xy = AIXM.xy
runway.forth.displaced_threshold = nil or Integer   # meters

runway.forth.magnetic_orientation   # => Integer (degrees)
```

#### Helipad

```ruby
helipad = AIXM.helipad(
  # TODO
)
```

#### Schedule

```ruby
schedule = AIXM.schedule(
  code: String or Symbol
)
schedule.remarks = String or nil
```

Some common values are available as convenience constants:

* `AIXM::H24` - continuous 24/7

#### Vertical Limits

```ruby
vertical_limits = AIXM.vertical_limits(
  max_z: AIXM.z or nil
  upper_z: AIXM.z
  lower_z: AIXM.z
  min_z: AIXM.z or nil
)
```

## Refinements

By `using AIXM::Refinements` you get the following general purpose methods:

* `Array#to_digest`<br>Build a 4 byte hex digest
* `Hash#lookup(key, default)`<br>Similar to `fetch` but falls back to values
* `String#indent(number)`<br>Indent every line of a string with *number* spaces
* `String#uptrans`<br>upcase and transliterate to match the reduced character set for names
* `String#to_dd`<br>Convert DMS angle to DD or `nil` if the format is not recognized
* `Float#to_dms(padding)`<br>Convert DD angle to DMS with the degrees zero padded to *padding* length
* `Float#to_rad`<br>Convert an angle from degree to radian
* `Float#trim`<br>Convert whole numbers to Integer and leave all other untouched
* `Float#to_km(from: unit)`<br>Convert a distance from *unit* (:km, :m, :nm or :ft) to km

See the [source code](https://github.com/svoop/aixm/blob/master/lib/aixm/refinements.rb) for more explicit descriptions and examples.

## References

### AIXM
* [AIXM](http://aixm.aero)
* [AICM 4.5 Documentation](https://openflightmaps.github.io/ofmx/aixm/4.5/manual/aicm/)
* [AIXM 4.5 Specification](http://aixm.aero/document/aixm-45-specification)

### OFMX
* [OFMX](https://github.com/openflightmaps/ofmx)
* [OFMX Documentation](https://github.com/openflightmaps/ofmx/wiki)
* [Open Flightmaps](https://openflightmaps.org)

## Tests

Some tests are very time consuming and therefore skipped by default. To run the full test suite, set the environment variable:

```
export SPEC_SCOPE=all
```

## Development

To install the development dependencies and then run the test suite:

```
bundle install
bundle exec rake    # run tests once
bundle exec guard   # run tests whenever files are modified
```

Please submit issues on:

https://github.com/svoop/aixm/issues

To contribute code, fork the project on Github, add your code and submit a pull request:

https://help.github.com/articles/fork-a-repo

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
