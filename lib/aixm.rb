require 'builder'
require 'forwardable'
require 'ostruct'
require 'digest'
require 'time'

require_relative 'aixm/version'

require_relative 'aixm/refinement'

require_relative 'aixm/xy'
require_relative 'aixm/z'
require_relative 'aixm/geometry'

require_relative 'aixm/horizontal/point'
require_relative 'aixm/horizontal/arc'
require_relative 'aixm/horizontal/border'
require_relative 'aixm/horizontal/circle'
require_relative 'aixm/vertical/limits'

require_relative 'aixm/constants'
require_relative 'aixm/config'

require_relative 'aixm/document'

require_relative 'aixm/feature/airspace'
