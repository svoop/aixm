module AIXM

  # Characters recognized as symbols for "minute" in DMS notations
  MIN = %Q('\u2018\u2019\u00b4)

  # Characters recognized as symbols for "second" in DMS notations 
  SEC = %Q("\u201c\u201d\u201f)

  # Pattern matching geographical coordinates in various DMS notations
  DMS_RE = %r(
    (?<dms>
      (?<sgn>-)?
      (?<deg>\d{1,3})[° ]{1,2}
      (?<min>\d{2})[#{MIN} ]{1,2}
      (?<sec>\d{2}(?:\.\d{0,2})?)[#{SEC}#{MIN} ]{0,2}
      (?<hem_ne>[NE])?(?<hem_sw>[SW])?
    |
      (?<sgn>-)?
      (?<deg>\d{1,3})
      (?<min>\d{2})
      (?<sec>\d{2}(?:\.\d{0,2})?)
      (?:(?<hem_ne>[NE])|(?<hem_sw>[SW]))
    )
  )xi.freeze

  # Pattern matching PCN surface strength notations
  PCN_RE = %r(
    (?<pcn>
      (?<capacity>\d+)\W+
      (?<type>[RF])\W+
      (?<subgrade>[A-D])\W+
      (?<tire_pressure>[W-Z])\W+
      (?<evaluation_method>[TU])
    )
  )x.freeze

end
