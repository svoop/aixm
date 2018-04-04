using AIXM::Refinements

module AIXM

  ##
  # Geographical coordinates
  #
  # The following notations for longitude and latitude are recognized:
  # * DD - examples: 12.12345678 (north or east), -12.12345678 (south or west)
  # * DMS - examples: 11°22'33.44"N, 1112233.44W
  class XY
    EARTH_RADIUS = 6_371_008.8   # meters

    def initialize(lat:, long:)
      self.lat, self.long = lat, long
    end

    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    def to_s
      [lat(:ofmx), long(:ofmx)].join(' ')
    end

    ##
    # Latitude
    def lat=(value)
      @lat = float_for value
      fail(ArgumentError, "invalid lat") unless (-90..90).include? @lat
    end

    def lat(schema = nil)
      case schema
        when :ofmx then ("%011.8f" % @lat.abs.round(8)) + (@lat.negative? ? 'S' : 'N')
        when :aixm then @lat.to_dms(2).gsub(/[^\d.]/, '') + (@lat.negative? ? 'S' : 'N')
        else @lat.round(8)
      end
    end

    ##
    # Longitude
    def long=(value)
      @long = float_for value
      fail(ArgumentError, "invalid long") unless (-180..180).include? @long
    end

    def long(schema = nil)
      case schema
        when :ofmx then ("%012.8f" % @long.abs.round(8)) + (@long.negative? ? 'W' : 'E')
        when :aixm then @long.to_dms(3).gsub(/[^\d.]/, '') + (@long.negative? ? 'W' : 'E')
        else @long.round(8)
      end
    end

    ##
    # Check whether two coordinate pairs are identical
    def ==(other)
      other.is_a?(self.class) && lat == other.lat && long == other.long
    end

    ##
    # Calculate the distance in meters by use of the Haversine formula
    def distance(other)
      if self == other
        0
      else
        2 * EARTH_RADIUS * Math.asin(
          Math.sqrt(
            Math.sin((other.lat.to_rad - lat.to_rad) / 2) ** 2 +
              Math.cos(lat.to_rad) * Math.cos(other.lat.to_rad) *
              Math.sin((other.long.to_rad - long.to_rad) / 2) ** 2
          )
        )
      end.round
    end

    private

    def float_for(value)
      case value
        when Numeric then value.to_f
        when String then value[0..-2].to_dd * (value.match?(/[SW]$/) ? -1 : 1)
        else fail(ArgumentError, "invalid value class `#{value.class}'")
      end
    rescue
      fail(ArgumentError, "invalid value `#{value}'")
    end

  end
end
