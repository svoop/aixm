[![Version](https://img.shields.io/gem/v/aixm.svg?style=flat)](https://rubygems.org/gems/aixm)
[![Continuous Integration](https://img.shields.io/travis/svoop/aixm/master.svg?style=flat)](https://travis-ci.org/svoop/aixm)
[![Code Climate](https://img.shields.io/codeclimate/github/svoop/aixm.svg?style=flat)](https://codeclimate.com/github/svoop/aixm)
[![Gitter](https://img.shields.io/gitter/room/svoop/aixm.svg?style=flat)](https://gitter.im/svoop/aixm)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

# AIXM

Partial implementation of the [Aeronautical Information Exchange Model (AIXM 4.5)](http://aixm.aero) and it's dialect [Open FlightMaps eXchange format (OFMX 0)](https://github.com/openflightmaps/ofmx) for Ruby.

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
document.aixm!   # not really necessary since AIXM is the default schema
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
AIXM.config.schema           # either :aixm (default) or :ofmx
AIXM.config.region           # fallback region
AIXM.config.ignored_errors   # ignore XML schema errors which match this regex
```

There are shortcuts to set and get the schema:

```ruby
AIXM.schema             # => :aixm
AIXM.aixm?              # => true
AIXM.ofmx!              # => :ofmx
AIXM.ofmx?              # => true
AIXM.schema             # => :ofmx
AIXM.schema(:version)   # => 0
```

## Validation

`AIXM::Document#valid?` validates the resulting AIXM or OFMX against its XML schema. If any, you find the errors in `AIXM::Document#errors`.

## Model

### Fundamental
* [Document](http://www.rubydoc.info/gems/aixm/AIXM/Document.html)
* [XY (longitude and latitude)](http://www.rubydoc.info/gems/aixm/AIXM/XY.html)
* [Z (height, elevation or altitude)](http://www.rubydoc.info/gems/aixm/AIXM/Z.html)
* [F (frequency)](http://www.rubydoc.info/gems/aixm/AIXM/F.html)

### Feature
* [Organisation](http://www.rubydoc.info/gems/aixm/AIXM/Feature/Organisation.html)
* [Airport](http://www.rubydoc.info/gems/aixm/AIXM/Feature/Airport.html)
* [Airspace](http://www.rubydoc.info/gems/aixm/AIXM/Feature/Airspace.html)
* Navigational aid
  * [Designated point](http://www.rubydoc.info/gems/aixm/AIXM/Feature/DesignatedPoint.html)
  * [DME](http://www.rubydoc.info/gems/aixm/AIXM/Feature/DME.html)
  * [Marker](http://www.rubydoc.info/gems/aixm/AIXM/Feature/Marker.html)
  * [NDB](http://www.rubydoc.info/gems/aixm/AIXM/Feature/NDB.html)
  * [TACAN](http://www.rubydoc.info/gems/aixm/AIXM/Feature/TACAN.html)
  * [VOR](http://www.rubydoc.info/gems/aixm/AIXM/Feature/VOR.html)

### Component
* [Geometry](http://www.rubydoc.info/gems/aixm/AIXM/Component/Geometry.html)
  * [Point](http://www.rubydoc.info/gems/aixm/AIXM/Component/Point.html)
  * [Arc](http://www.rubydoc.info/gems/aixm/AIXM/Component/Arc.html)
  * [Border](http://www.rubydoc.info/gems/aixm/AIXM/Component/Border.html)
  * [Circle](http://www.rubydoc.info/gems/aixm/AIXM/Component/Circle.html)
* [Runway](http://www.rubydoc.info/gems/aixm/AIXM/Component/Runway.html)
* [Helipad](http://www.rubydoc.info/gems/aixm/AIXM/Component/Helipad.html)
* [Layer](http://www.rubydoc.info/gems/aixm/AIXM/Component/Layer.html)
* [Vertical limits](http://www.rubydoc.info/gems/aixm/AIXM/Component/VerticalLimits.html)
* [Schedule](http://www.rubydoc.info/gems/aixm/AIXM/Component/Schedule.html)

## Refinements

By `using AIXM::Refinements` you get a few handy [extensions to Ruby core classes](http://www.rubydoc.info/gems/aixm/AIXM/Refinements.html).

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
