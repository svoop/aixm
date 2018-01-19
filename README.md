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
* Author: [Sven Schwyn - Bitcetera](http://www.bitcetera.com)

## Install

Add this to your <tt>Gemfile</tt>:

```ruby
gem aixm
```

## Usage

### Types

#### Coordinate

All of the below are equivalent:

```ruby
AIXM::XY.new(lat: %q(11°22'33.44"), long: %q(-111°22'33.44"))
AIXM::XY.new(lat: '112233.44N', long: '1112233.44W')
AIXM::XY.new(lat: 11.375955555555556, long: -111.37595555555555)
```

#### Altitude

```ruby
AIXM::Z.new(alt: 1000, code: :QFE)   # height: 1000ft above ground
AIXM::Z.new(alt: 2000, code: :QNH)   # altitude: of 2000ft above mean sea level
AIXM::Z.new(alt: 45, code: :QNE)     # altitude: flight level 45
```

### Document

See <tt>spec/factory.rb</tt> for examples.

## Rendering

```ruby
document.to_xml         # render AIXM 4.5 compliant XML
document.to_xml(:OFM)   # render AIXM 4.5 + OFM extensions XML
```

## Constants

* <tt>AIXM::GROUND</tt> - height: 0ft above ground
* <tt>AIXM::UNLIMITED</tt> - altitude: FL 999
* <tt>AIXM::H24</tt> - continuous schedule

## Refinements

By `using AIXM::Refinements` you get the following general purpose methods:

* <tt>String#indent(number)</tt><br>Indent every line of a string with *number* spaces
* <tt>String#to_dd</tt><br>Convert DMS angle to DD or <tt>nil</tt> if the format is not recognized
* <tt>Float#to_dms(padding)</tt><br>Convert DD angle to DMS with the degrees zero padded to *padding* length
* <tt>Float#trim</tt><br>Convert whole numbers to Integer and leave all other untouched
* <tt>Float#to_km(from: unit)</tt><br>Convert a distance from *unit* (:km, :m, :nm or :ft) to km

## Extensions

### OFM

This extension adds proprietary tags and attributes (most of which are prefixed
with `xt_`) aiming to improve importing the resulting AIXM into the OGN
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
