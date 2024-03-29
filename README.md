[![Version](https://img.shields.io/gem/v/aixm.svg?style=flat)](https://rubygems.org/gems/aixm)
[![Tests](https://img.shields.io/github/actions/workflow/status/svoop/aixm/test.yml?style=flat&label=tests)](https://github.com/svoop/aixm/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/svoop/aixm.svg?style=flat)](https://codeclimate.com/github/svoop/aixm/)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/svoop.svg)](https://github.com/sponsors/svoop)

# AIXM

Partial implementation of the [Aeronautical Information Exchange Model (AIXM 4.5)](http://aixm.aero) and it's dialect [Open FlightMaps eXchange format (OFMX 0)](https://gitlab.com/openflightmaps/ofmx/wikis) for Ruby.

For now, only the parts needed to automize the AIP import of [open flightmaps](https://openflightmaps.org) are part of this gem. Most notably, the gem is only a builder for snapshot files and does not parse them.

* [Homepage](https://github.com/svoop/aixm)
* [API](https://www.rubydoc.info/gems/aixm)
* Author: [Sven Schwyn - Bitcetera](https://bitcetera.com)

Thank you for supporting free and open-source software by sponsoring on [GitHub](https://github.com/sponsors/svoop) or on [Donorbox](https://donorbox.com/bitcetera). Any gesture is appreciated, from a single Euro for a ☕️ cup of coffee to 🍹 early retirement.

## Install

### Security

This gem is [cryptographically signed](https://guides.rubygems.org/security/#using-gems) in order to assure it hasn't been tampered with. Unless already done, please add the author's public key as a trusted certificate now:

```
gem cert --add <(curl -Ls https://raw.github.com/svoop/aixm/main/certs/svoop.pem)
```

### Bundler

Add the following to the <tt>Gemfile</tt> or <tt>gems.rb</tt> of your [Bundler](https://bundler.io) powered Ruby project:

```ruby
gem 'aixm'
```

And then install the bundle:

```
bundle install --trust-policy MediumSecurity
```

### Standalone

If you're only going to use [the executables](#executables), make sure to have the [latest version of Ruby](https://www.ruby-lang.org/en/documentation/installation/) and then install this gem:

```
gem install aixm --trust-policy MediumSecurity
```

## Usage

Here's how to build a document object, populate it with a simple feature and then render it as AIXM or OFMX:

```ruby
document = AIXM.document(
  region: 'LF'
)
document.add_feature(
  AIXM.designated_point(
    id: "ABIXI",
    xy: AIXM.xy(lat: %q(46°31'54.3"N), long: %q(002°19'55.2"W)),
    type: :icao
  )
)
AIXM.ofmx!
document.to_xml
```

You can initialize all elements either traditionally or by use of the corresponding shorthand AIXM class method. The following two statements are identical:

```ruby
AIXM::Feature::NavigationalAid::DesignatedPoint.new(...)
AIXM.designated_point(...)
```

See `AIXM::CLASSES` for the complete list of shorthand names.

## Configuration

### AIXM.config.schema

The schema is either `:aixm` (default) or `:ofmx`:

```ruby
AIXM.config.schema = :ofmx   # =>:ofmx
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

### AIXM.config.region

The `:ofmx` schema requires the [region to be set on all core features](https://gitlab.com/openflightmaps/ofmx/wikis/Features#core-features). You can do so on individual features, however, you might want to configure a default region to simplify your life:

```ruby
AIXM.ofmx!
AIXM.config.region = 'LF'
```

:warning: This setting has no effect when using the `:aixm` schema.

### AIXM.voice_channel_separation

Define which voice channel separation should be used to validate voice communication frequencies.

```ruby
AIXM.voice_channel_separation = :any   # both 25 and 8.33 kHz (default)
AIXM.voice_channel_separation = 25     # 25 kHz only
AIXM.voice_channel_separation = 833    # 8.33 kHz only
```

### AIXM.config.mid

In order to insert [OFMX-compliant `mid` attributes](https://gitlab.com/openflightmaps/ofmx/wikis/Features#mid) into all `*Uid` elements, you have set the mid configuration option to `true`.

```ruby
AIXM.ofmx!
AIXM.config.mid = false   # don't insert mid attributes (default)
AIXM.config.mid = true    # insert mid attributes
```

:warning: This setting has no effect when using the `:aixm` schema.

### AIXM.config.ignored_errors

In case you want to ignore certain XML schema validation errors, set this configuration option to a regular expression which matches the error messages to ignore. By default, no errors are ignored.

```ruby
AIXM.config.ignored_errors = /invalid date/i
```

## Models

### Fundamentals
* [Document](https://www.rubydoc.info/gems/aixm/AIXM/Document.html)
* [A (angle)](https://www.rubydoc.info/gems/aixm/AIXM/A.html)
* [D (dimension, distance or length)](https://www.rubydoc.info/gems/aixm/AIXM/D.html)
* [F (frequency)](https://www.rubydoc.info/gems/aixm/AIXM/F.html)
* [P (pressure)](https://www.rubydoc.info/gems/aixm/AIXM/P.html)
* [R (rectangle)](https://www.rubydoc.info/gems/aixm/AIXM/R.html)
* [XY (longitude and latitude)](https://www.rubydoc.info/gems/aixm/AIXM/XY.html)
* [Z (height, elevation or altitude)](https://www.rubydoc.info/gems/aixm/AIXM/Z.html)

### Features
* [Address](https://www.rubydoc.info/gems/aixm/AIXM/Feature/Address.html)
* [Airport](https://www.rubydoc.info/gems/aixm/AIXM/Feature/Airport.html)
* [Airspace](https://www.rubydoc.info/gems/aixm/AIXM/Feature/Airspace.html)
* [Navigational aid](https://www.rubydoc.info/gems/aixm/AIXM/NavigationalAid.html)
  * [Designated point](https://www.rubydoc.info/gems/aixm/AIXM/Feature/DesignatedPoint.html)
  * [DME](https://www.rubydoc.info/gems/aixm/AIXM/Feature/DME.html)
  * [Marker](https://www.rubydoc.info/gems/aixm/AIXM/Feature/Marker.html)
  * [NDB](https://www.rubydoc.info/gems/aixm/AIXM/Feature/NDB.html)
  * [TACAN](https://www.rubydoc.info/gems/aixm/AIXM/Feature/TACAN.html)
  * [VOR](https://www.rubydoc.info/gems/aixm/AIXM/Feature/VOR.html)
* [Obstacle](https://www.rubydoc.info/gems/aixm/AIXM/Feature/Obstacle.html)
* [Obstacle group](https://www.rubydoc.info/gems/aixm/AIXM/Feature/ObstacleGroup.html)
* [Organisation](https://www.rubydoc.info/gems/aixm/AIXM/Feature/Organisation.html)
* [Service](https://www.rubydoc.info/gems/aixm/AIXM/Component/Service.html)
* [Unit](https://www.rubydoc.info/gems/aixm/AIXM/Feature/Unit.html)
* [Generic](https://www.rubydoc.info/gems/aixm/AIXM/Feature/Generic.html)

### Components

* [ApproachLighting](https://www.rubydoc.info/gems/aixm/AIXM/Component/ApproachLighting.html)
* [FATO](https://www.rubydoc.info/gems/aixm/AIXM/Component/FATO.html)
* [Frequency](https://www.rubydoc.info/gems/aixm/AIXM/Component/Frequency.html)
* [Geometry](https://www.rubydoc.info/gems/aixm/AIXM/Component/Geometry.html)
  * [Arc](https://www.rubydoc.info/gems/aixm/AIXM/Component/Arc.html)
  * [Border](https://www.rubydoc.info/gems/aixm/AIXM/Component/Border.html)
  * [Circle](https://www.rubydoc.info/gems/aixm/AIXM/Component/Circle.html)
  * [Point](https://www.rubydoc.info/gems/aixm/AIXM/Component/Point.html)
  * [RhumbLine](https://www.rubydoc.info/gems/aixm/AIXM/Component/RhumbLine.html)
* [Helipad](https://www.rubydoc.info/gems/aixm/AIXM/Component/Helipad.html)
* [Layer](https://www.rubydoc.info/gems/aixm/AIXM/Component/Layer.html)
* [Lighting](https://www.rubydoc.info/gems/aixm/AIXM/Component/Lighting.html)
* [Runway](https://www.rubydoc.info/gems/aixm/AIXM/Component/Runway.html)
* [Service](https://www.rubydoc.info/gems/aixm/AIXM/Component/Service.html)
* [Surface](https://www.rubydoc.info/gems/aixm/AIXM/Component/Surface.html)
* [Timetable](https://www.rubydoc.info/gems/aixm/AIXM/Component/Timetable.html)
* [Timesheet](https://www.rubydoc.info/gems/aixm/AIXM/Component/Timesheet.html)
* [VASIS](https://www.rubydoc.info/gems/aixm/AIXM/Component/VASIS.html)
* [Vertical limit](https://www.rubydoc.info/gems/aixm/AIXM/Component/VerticalLimit.html)

### Schedule

* [Date](https://www.rubydoc.info/gems/aixm/AIXM/Schedule/Date.html)
* [Day](https://www.rubydoc.info/gems/aixm/AIXM/Schedule/Day.html)
* [Time](https://www.rubydoc.info/gems/aixm/AIXM/Schedule/Time.html)
* [DateTime](https://www.rubydoc.info/gems/aixm/AIXM/Schedule/DateTime.html)

## Associations

The different models are interwoven with [`has_many` and `has_one` associations](https://www.rubydoc.info/gems/aixm/AIXM/Association).

Please note that `has_many` associations are instances `AIXM::Concerns::Association::Array` which mostly behave like normal arrays. However, you must not add or remove elements on the array directly but use the corresponding method on the associating model instead:

```ruby
document.features << airport   # => NoMethodError
document.add_feature airport   # okay
```

### find_by and find

Use `find_by` on `has_many` to filter associations by class and optional attribute values:

```ruby
document.features.find_by(:airport)               # => [#<AIXM::Feature::Airport>, #<AIXM::Feature::Airport>]
document.features.find_by(:airport, id: 'LFNT')   # => [#<AIXM::Feature::Airport>]
```

To search a `has_many` association for equal objects, use `find`:

```ruby
document.features.find(airport)   # => [#<AIXM::Feature::Airport>]
```

This may seem redundant at first, but keep in mind that two instances of +AIXM::CLASSES+ which implement `#to_uid` are considered equal if they are instances of the same class and both their UIDs as calculated by `#to_uid` are equal. Attributes which are not part of the `#to_uid` calculation are irrelevant!

### meta

You can write arbitrary meta information to any feature or component. It won't be used when building the AIXM or OFMX document, in fact, it is not used by this gem at all. But you can store e.g. foreign keys and then later use them to find a feature or component like so:

```ruby
document.features.find_by(:airport, meta: 1234)   # 1234 is the foreign key
```

### duplicates

Equally on `has_many` associations, use `duplicates` to find identical or equal associations:

```ruby
document.features.duplicates   # => [#<AIXM::Feature::Unit>, #<AIXM::Component::Service>, ...]
```

## XML Comments

All features implement the `comment` attribute which accepts any object and converts it `#to_s`. When set, an XML comment is inserted right after the opening tag of the feature. This comes in handy e.g. in case you want to include source data facsimile such as NOTAM. Oneline and multiline comments are inserted differently:

```xml
<Ase>
  <!--
    B0330/22 NOTAMR B1756/21
    Q) LSAS/QAFLT/V/NBO/E/000/050/4734N00841E005
    A) LSAS B) 2203170746 C) 2206242359 EST
  -->
  <AseUid>
    <codeType>RAS</codeType>
    <codeId>B0330/22</codeId>
  </AseUid>
  (...)
</Ase>

<Org>
  <!-- Generic organisation -->
  <OrgUid>
    <txtName>FRANCE</txtName>
  </OrgUid>
  (...)
</Org>
```

## Payload Hash

OFMX defines a [payload hash function](https://gitlab.com/openflightmaps/ofmx/wikis/Functions) used to facilitate association and modification tracking. It is used internally, but you can also use it in your own code:

```ruby
# Payload hash of XML fragment string
xml = '<xml><a></a></xml>'
AIXM::PayloadHash.new(xml).to_uuid

# Payload hash of Nokogiri XML fragment
document = File.open("file.xml") { Nokogiri::XML(_1) }
AIXM::PayloadHash.new(document).to_uuid
```

## Validation

`AIXM::Document#valid?` validates the resulting AIXM or OFMX against its XML schema. If any, you find the errors in `AIXM::Document#errors`.

## Refinements

By `using AIXM::Refinements` you get a few handy [extensions to Ruby core classes](https://www.rubydoc.info/gems/aixm/AIXM/Refinements.html).

## Executables

### mkmid

The `mkmid` executable reads OFMX files, adds [OFMX-compliant `mid` values](https://gitlab.com/openflightmaps/ofmx/wikis/Features#mid) into all `*Uid` elements and validates the result against the schema.

```
mkmid --help
```

### ckmid

The `chmid` executable reads OFMX files, validates them against the schema and checks all `mid` attributes for [OFMX-compliance](https://gitlab.com/openflightmaps/ofmx/wikis/Features#mid).

```
ckmid --help
```

## References

### AIXM
* [AIXM](http://aixm.aero)
* [AICM 4.5 documentation](https://openflightmaps.gitlab.io/ofmx/aixm/4.5/manual/aicm/)
* [AICM 4.5 manual](https://www.aixm.aero/sites/aixm.aero/files/imce/library/aicm_manual_4-5.pdf)
* [AIXM 4.5 specification](http://aixm.aero/document/aixm-45-specification)

### OFMX
* [OFMX](https://gitlab.com/openflightmaps/ofmx)
* [OFMX documentation](https://gitlab.com/openflightmaps/ofmx/wikis)
* [open flightmaps](https://openflightmaps.org)

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

You're welcome to [submit issues](https://github.com/svoop/aixm/issues) and contribute code by [forking the project and submitting pull requests](https://docs.github.com/en/get-started/quickstart/fork-a-repo).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
