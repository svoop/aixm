module AIXM

  MIN = %Q('\u2018\u2019\u00b4)
  SEC = %Q("\u201c\u201d\u201f)
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

end
