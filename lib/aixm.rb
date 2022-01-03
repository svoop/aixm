require 'bigdecimal'
require 'ostruct'
require 'time'
require 'pathname'
require 'securerandom'
require 'forwardable'
require 'digest'
require 'optparse'

require 'builder'
require 'nokogiri'
require 'dry/inflector'

require_relative 'aixm/object'

require_relative 'aixm/version'
require_relative 'aixm/refinements'
require_relative 'aixm/config'
require_relative 'aixm/errors'

require_relative 'aixm/classes'
require_relative 'aixm/constants'
require_relative 'aixm/memoize'
require_relative 'aixm/association'
require_relative 'aixm/payload_hash'

require_relative 'aixm/document'
require_relative 'aixm/xy'
require_relative 'aixm/z'
require_relative 'aixm/d'
require_relative 'aixm/r'
require_relative 'aixm/f'
require_relative 'aixm/a'
require_relative 'aixm/w'
require_relative 'aixm/p'

require_relative 'aixm/component/service'
require_relative 'aixm/component/frequency'
require_relative 'aixm/component/geometry'
require_relative 'aixm/component/geometry/point'
require_relative 'aixm/component/geometry/rhumb_line'
require_relative 'aixm/component/geometry/arc'
require_relative 'aixm/component/geometry/circle'
require_relative 'aixm/component/geometry/border'
require_relative 'aixm/component/layer'
require_relative 'aixm/component/vertical_limit'
require_relative 'aixm/component/timetable'
require_relative 'aixm/component/runway'
require_relative 'aixm/component/fato'
require_relative 'aixm/component/helipad'
require_relative 'aixm/component/surface'
require_relative 'aixm/component/vasis'
require_relative 'aixm/component/lighting'
require_relative 'aixm/component/approach_lighting'

require_relative 'aixm/feature'
require_relative 'aixm/feature/address'
require_relative 'aixm/feature/organisation'
require_relative 'aixm/feature/unit'
require_relative 'aixm/feature/airspace'
require_relative 'aixm/feature/airport'
require_relative 'aixm/feature/navigational_aid'
require_relative 'aixm/feature/navigational_aid/designated_point'
require_relative 'aixm/feature/navigational_aid/dme'
require_relative 'aixm/feature/navigational_aid/marker'
require_relative 'aixm/feature/navigational_aid/ndb'
require_relative 'aixm/feature/navigational_aid/tacan'
require_relative 'aixm/feature/navigational_aid/vor'
require_relative 'aixm/feature/obstacle'
require_relative 'aixm/feature/obstacle_group'

require_relative 'aixm/shortcuts'
require_relative 'aixm/executables'
