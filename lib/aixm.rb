require 'builder'
require 'nokogiri'
require 'forwardable'
require 'ostruct'
require 'digest'
require 'time'

require_relative 'aixm/version'
require_relative 'aixm/refinements'

require_relative 'aixm/document'
require_relative 'aixm/xy'
require_relative 'aixm/z'

require_relative 'aixm/component/base'
require_relative 'aixm/component/geometry'
require_relative 'aixm/component/geometry/point'
require_relative 'aixm/component/geometry/arc'
require_relative 'aixm/component/geometry/border'
require_relative 'aixm/component/geometry/circle'
require_relative 'aixm/component/class_layer'
require_relative 'aixm/component/vertical_limits'
require_relative 'aixm/component/schedule'

require_relative 'aixm/feature/airspace'

require_relative 'aixm/shortcuts'
