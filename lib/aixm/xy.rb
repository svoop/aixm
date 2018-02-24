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
      @lat, @long = float_for(lat), float_for(long)
      fail(ArgumentError, "illegal latitude") unless (-90..90).include? @lat
      fail(ArgumentError, "illegal longitude") unless (-180..180).include? @long
    end

    def lat(format = nil)
      case format
        when :ofmx then ("%.8f" % @lat.abs.round(8)) + (@lat.negative? ? 'S' : 'N')
        when :aixm then @lat.to_dms(2).gsub(/[^\d.]/, '') + (@lat.negative? ? 'S' : 'N')
        else @lat.round(8)
      end
    end

    def long(format = nil)
      case format
        when :ofmx then ("%.8f" % @long.abs.round(8)) + (@long.negative? ? 'W' : 'E')
        when :aixm then @long.to_dms(3).gsub(/[^\d.]/, '') + (@long.negative? ? 'W' : 'E')
        else @long.round(8)
      end
    end

    def to_digest
      [lat, long].to_digest
    end

    def ==(other)
      other.is_a?(XY) && lat == other.lat && long == other.long
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
        when String then value[0..-2].to_dd * (value =~ /[SW]$/ ? -1 : 1)
        else fail(ArgumentError, "illegal value class `#{value.class}'")
      end
    rescue
      fail(ArgumentError, "illegal value `#{value}'")
    end

  end
end
