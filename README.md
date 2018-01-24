[![Version](https://img.shields.io/gem/v/aixm.svg?style=flat)](https://rubygems.org/gems/aixm)
[![Continuous Integration](https://img.shields.io/travis/svoop/aixm/master.svg?style=flat)](https://travis-ci.org/svoop/aixm)
[![Code Climate](https://img.shields.io/codeclimate/github/svoop/aixm.svg?style=flat)](https://codeclimate.com/github/svoop/aixm)
[![Gitter](https://img.shields.io/gitter/room/svoop/aixm.svg?style=flat)](https://gitter.im/svoop/aixm)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

# AIXM

Partial implementation of the [Aeronautical Information Exchange Model (AIXM 4.5)](http://aixm.aero)
for Ruby.

For now, only the parts needed to automize the AIP import of [Open Flightmaps](https://openflightmaps.org)
are part of this gem. Most notably, the gem is only a builder of AIXM 4.5
snapshot files and does not parse them.

* [Homepage](https://github.com/svoop/aixm)
* [API](http://www.rubydoc.info/gems/aixm)
* Author: [Sven Schwyn - Bitcetera](http://www.bitcetera.com)

## Install

Add this to your `Gemfile`:

```ruby
gem aixm
```

## Usage

You can initialize all elements either traditionally or by use of shorter
AIXM class methods:

```ruby
AIXM.airspace(...)
AIXM.airspace(...)
```

### Fundamentals

All fundamentals are bundled at the root of the module `AIXM`.

### Document

The document is the root container of the AIXM snapshot file to be generated.
It's essentially a collection of features:

```ruby
document = AIXM.document(created_at: Time.now, effective_at: Time.now)
document.features << AIXM.airspace(...)
```

To give an overview of the AIXM building blocks, the remainder of this guide
will list initializer arguments with colons (`name: class`) and attribute
writers with equal or push signs (`name = class` or `name << class`):

* AIXM.document
  * created_at: Time, Date or String
  * effective_at: Time, Date or String
  * features << AIXM::Feature

See [the API documentation](http://www.rubydoc.info/gems/aixm) for details and
[spec/factory.rb](https://github.com/svoop/aixm/blob/master/spec/factory.rb) for
examples.

#### Coordinate

All of the below are equivalent:

```ruby
AIXM.xy(lat: %q(11°22'33.44"), long: %q(-111°22'33.44"))
AIXM.xy(lat: '112233.44N', long: '1112233.44W')
AIXM.xy(lat: 11.375955555555556, long: -111.37595555555555)
```

#### Altitude and Heights

Altitudes and heights exist in three different forms:

```ruby
AIXM.z(1000, :QFE)   # height: 1000ft above ground
AIXM.z(2000, :QNH)   # altitude: of 2000ft above mean sea level
AIXM.z(45, :QNE)     # altitude: flight level 45
```

#### Frequency

```ruby
AIXM.f(123.35, :MHZ)
```

### Features

All features are subclasses of `AIXM::Feature`.

#### Airspace

* AIXM.airspace
  * name: String
  * short_name: String or *nil*
  * type: String or Symbol
  * schedule = AIXM.schedule
  * geometry << AIXM.point, AIXM.arc, AIXM.border or AIXM.circle
  * class_layers << AIXM.class_layer
  * remarks = String

### Components

All components are subclasses of `AIXM::Component`.

#### Schedule

* AIXM.schedule
  * code: String or Symbol

#### Class Layer

* AIXM.class_layer
  * class: String or *nil*
  * vertical_limits: AIXM.vertical_limits

#### Vertical Limits

* AIXM.vertical_limits
  * max_z: AIXM.z or *nil*
  * upper_z: AIXM.z
  * lower_z: AIXM.z
  * min_z: AIXM.z or *nil*

#### Point, Arc, Border and Circle

* AIXM.point
  * xy: AIXM.xy
* AIXM.arc
  * xy: AIXM.xy
  * center_xy: AIXM.xy
  * cloclwise: *true* or *false*
* AIXM.border
  * xy: AIXM.xy
  * name: String
* AIXM.circle
  * center_xy: AIXM.xy
  * radius: Numeric

#### Geometry

* AIXM.geometry
  * << AIXM.point, AIXM.arc, AIXM.border or AIXM.circle

For a geometry to be complete, it must be comprised of either:

* exactly one circle
* at least three points, arcs or borders (the last of which a point with
  identical coordinates as the first)

## Validation

* Use `AIXM::Document#complete?` to check whether all mandatory information is
present. Airspaces, geometries etc have `complete?` methods as well.
* Use `AIXM::Document#valid?` to validate the resulting AIXM against the XSD
schema. If any, you find the errors in `AIXM::Document#errors`.

## Rendering

```ruby
document.to_xml         # render AIXM 4.5 compliant XML
document.to_xml(:OFM)   # render AIXM 4.5 + OFM extensions XML
```

## Constants

* `AIXM::GROUND` - height: 0ft above ground
* `AIXM::UNLIMITED` - altitude: FL 999
* `AIXM::H24` - continuous schedule

## Refinements

By `using AIXM::Refinements` you get the following general purpose methods:

* `Hash#lookup(key, default)`<br>Similar to `fetch` but falls back to values
* `String#indent(number)`<br>Indent every line of a string with *number* spaces
* `String#uptrans`<br>upcase and transliterate to match the reduced character set for names
* `String#to_dd`<br>Convert DMS angle to DD or `nil` if the format is not recognized
* `Float#to_dms(padding)`<br>Convert DD angle to DMS with the degrees zero padded to *padding* length
* `Float#trim`<br>Convert whole numbers to Integer and leave all other untouched
* `Float#to_km(from: unit)`<br>Convert a distance from *unit* (:km, :m, :nm or :ft) to km

See the [source code](https://github.com/svoop/aixm/blob/master/lib/aixm/refinements.rb)
for more explicit descriptions and examples.

## Extensions

### OFM

This extension adds proprietary tags and attributes (most of which are prefixed
with `xt_`) aiming to improve importing the resulting AIXM into the OFM
originative suite:

* `<AIXM-Snapshot version="4.5 + OFM extensions of version 0.1" (...) />`<br>root node with extended version string
* `<Ase xt_classLayersAvail="(true|false)">`<br>true when multiple class layers and therefore an Adg-node is present
* `<xt_selAvail>(true|false)</xt_selAvail>`<br>enables conditional airspaces feature
* `<AseUid newEntity="(true|false)">`<br>tell the importer whether adding a new or updating an existing entity

## References

* [AIXM](http://aixm.aero)
* [AIXM on Wikipedia](https://en.wikipedia.org/wiki/AIXM)
* [Open Flightmaps](https://openflightmaps.org)

## Tests

Some tests are very time consuming and therefore skipped by default. To run the
full test suite, set the environment variable:

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

To contribute code, fork the project on Github, add your code and submit a
pull request:

https://help.github.com/articles/fork-a-repo

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
