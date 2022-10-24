using AIXM::Refinements

module AIXM

  # Shortcut initializers
  CLASSES.each do |element, class_name|
    define_singleton_method(element) do |*args, **kwargs|
      class_name.to_class.new(*args, **kwargs)
    end
  end

  # Ground level
  GROUND = z(0, :qfe).freeze

  # Max flight level used to signal "no upper limit"
  UNLIMITED = z(999, :qne).freeze

  # Day to signal "whatever date or day"
  ANY_DAY = AIXM.day(:any).freeze

  # Timetable used to signal "always active"
  H24 = timetable(code: :H24).freeze

  # Time which marks midnight at beginning of the day
  BEGINNING_OF_DAY = AIXM.time('00:00').freeze

  # Time which marks midnight at end of the day
  END_OF_DAY = AIXM.time('24:00').freeze

end
