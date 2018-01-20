## 0.1.1

* Additions:
  * Schedule (all but TIMSH)
  * Refinement Float#to_km and String#uptrans
  * Constants AIXM::UNLIMITED and AIXM::H24
  * Airspace#short_name
* Minor changes:
  * Document#created_at and #effective_at accept Time, Date, String or nil
  * Separate AIXM::Document#valid? from #complete?
  * Write coordinates in DD if extension :OFM is set
  * Array#to_digest returns integer which fits in signed 32bit

## 0.1.0

* Initial implementation to import D/R/P zones to OFM:
  * XY Coordinate
  * Z Altitude
  * AIXM-Snapshot 4.5 Document
  * Airspace
  * Vertical Limits
  * Geometry
    * Point
    * Arc
    * Border
    * Circle
  * Constant AIXM::GROUND
  * Refinements
