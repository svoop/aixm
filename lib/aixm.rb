require 'builder'
require 'nokogiri'
require 'forwardable'
require 'digest'
require 'time'

require_relative 'aixm/version'
require_relative 'aixm/refinements'
require_relative 'aixm/format'

require_relative 'aixm/document'
require_relative 'aixm/xy'
require_relative 'aixm/z'
require_relative 'aixm/f'

require_relative 'aixm/component/geometry'
require_relative 'aixm/component/geometry/point'
require_relative 'aixm/component/geometry/arc'
require_relative 'aixm/component/geometry/border'
require_relative 'aixm/component/geometry/circle'
require_relative 'aixm/component/layer'
require_relative 'aixm/component/vertical_limits'
require_relative 'aixm/component/schedule'
require_relative 'aixm/component/runway'

require_relative 'aixm/feature/airspace'
require_relative 'aixm/feature/airport'
require_relative 'aixm/feature/navigational_aid/base'
require_relative 'aixm/feature/navigational_aid/designated_point'
require_relative 'aixm/feature/navigational_aid/dme'
require_relative 'aixm/feature/navigational_aid/marker'
require_relative 'aixm/feature/navigational_aid/ndb'
require_relative 'aixm/feature/navigational_aid/tacan'
require_relative 'aixm/feature/navigational_aid/vor'

require_relative 'aixm/shortcuts'
