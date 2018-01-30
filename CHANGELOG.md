## 0.3.0

* Additions
  * Refinement `Float#to_rad`
  * Distance calculation with `AIXM::XY#distance`

## 0.2.3

* Breaking minor changes:
  * VOR types renamed from :vor to :conventional and :doppler_vor to :doppler
  * NBR types added
  * Marker types added
* Minor changes:
  * "mid" attributes on all navigational aid features

## 0.2.2

* Minor changes:
  * Bad error classes fixed
  * Allow navigational aids without name

## 0.2.1

* Major changes:
  * DVOR and VORDME confusion fixed
  * Schedule added to navigational aids
  * VOR can be associated with DME (-> VOR/DME) or TACAN (-> VORTAC) now
  * `to_xml` renamed to `to_aixm` everywhere
* Minor changes:
  * Removed :other from all value lists

## 0.2.0

* Additions:
  * Frequency
  * Navigational aids features
  * `AIXM::Z#qfe?` and friends
* Breaking major changes:
  * Symbols such as :qnh, :ofm or :mhz are downcased now

## 0.1.4

* Breaking minor changes:
  * `AIXM.z(alt: 123, code: :QNE)` is now `AIXM.z(123, :QNE)`

## 0.1.3

* Breaking major changes:
  * Re-organization of classes in features and components
* Additions:
  * Shortcut initializers e.g. `AIXM.airspace(...)`

## 0.1.2

* Breaking additions:
  * Class layers
* Breaking minor changes:
  * Use `document.features << (feature)` instead of `document << (feature)`

## 0.1.1

* Additions:
  * Schedule (all but `TIMSH`)
  * Refinement `Float#to_km` and `String#uptrans`
  * Shortcut constants `AIXM::UNLIMITED` and `AIXM::H24`
  * `Airspace#short_name`
* Minor changes:
  * `Document#created_at` and `#effective_at` accept Time, Date, String or *nil*
  * Separate `AIXM::Document#valid?` from `#complete?`
  * Write coordinates in DD if extension `:OFM` is set
  * `Array#to_digest` returns Integer which fits in signed 32bit

## 0.1.0

* Initial implementation to import D/R/P zones to OFM:
  * XY Coordinate
  * Z Altitude
  * AIXM-Snapshot 4.5 Document
  * Airspace feature
  * Vertical Limits
  * Geometry
    * Point
    * Arc
    * Border
    * Circle
  * Shortcut constant `AIXM::GROUND`
  * Refinements
