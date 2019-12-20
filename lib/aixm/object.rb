# This monkey patch is necessary because some classes have to introduce
# attributes named +class+ (e.g. for airspace classes as described by
# +AIXM::Component::Layer+) which clash with this core method. Other parts
# such as +AIXM::Association+ need the original implementation for introspection
# which is why this alias +Object#__class__+ makes it globally and consistently
# available again.
class Object
  alias_method :__class__, :class
end
