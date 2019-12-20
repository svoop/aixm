using AIXM::Refinements

module AIXM

  # Shortcut initializers
  CLASSES.each do |element, class_name|
    define_singleton_method(element) do |*arguments|
      class_name.to_class.new(*arguments)
    end
  end

  # Ground level
  GROUND = z(0, :qfe).freeze

  # Max flight level used to signal "no upper limit"
  UNLIMITED = z(999, :qne).freeze

  # Timetable used to signal "always active"
  H24 = timetable(code: :H24).freeze

end
