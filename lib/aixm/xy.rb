using AIXM::Refinements

module AIXM

  # Geographical coordinates
  #
  # ===Recognized notations:
  # * DD - examples: 12.12345678 (north or east), -12.12345678 (south or west)
  # * DMS - examples: 11°22'33.44"N, 1112233.44W,
  #
  # @example All of the below are equivalent
  #   AIXM.xy(lat: 11.375955555555556, long: -111.37595555555555)
  #   AIXM.xy(lat: %q(11°22'33.44"), long: %q(-111°22'33.44"))
  #   AIXM.xy(lat: %q(11°22'33.44N"), long: %q(111°22'33.44W"))
  #   AIXM.xy(lat: '112233.44N', long: '1112233.44W')
  #
  # ===Constants:
  # * +AIXM::MIN+ - characters recognized as DMS minute symbols
  # * +AIXM::SEC+ - characters recognized as DMS second symbols
  # * +AIXM::DMS_RE+ - regular expression to match DMS coordinate notations
  #
  # @see https://github.com/openflightmaps/ofmx/wiki/Coordinates
  class XY
    EARTH_RADIUS = 6_371_008.8

    def initialize(lat:, long:)
      self.lat, self.long = lat, long
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation
    def to_s
      [lat(:ofmx), long(:ofmx)].join(' ')
    end

    # @!attribute lat
    def lat=(value)
      @lat = float_for value
      fail(ArgumentError, "invalid lat") unless (-90..90).include? @lat
    end

    # @param schema [Symbol, nil] either nil, +:aixm+ or +:ofmx+
    # @return [String, Float] latitude
    def lat(schema=nil)
      case schema
        when :ofmx then ("%011.8f" % @lat.abs.round(8)) + (@lat.negative? ? 'S' : 'N')
        when :aixm then @lat.to_dms(2).gsub(/[^\d.]/, '') + (@lat.negative? ? 'S' : 'N')
        else @lat.round(8)
      end
    end

    # @!attribute long
    def long=(value)
      @long = float_for value
      fail(ArgumentError, "invalid long") unless (-180..180).include? @long
    end

    # @param schema [Symbol, nil] either nil, +:aixm+ or +:ofmx+
    # @return [Float, String] longitude
    def long(schema=nil)
      case schema
        when :ofmx then ("%012.8f" % @long.abs.round(8)) + (@long.negative? ? 'W' : 'E')
        when :aixm then @long.to_dms(3).gsub(/[^\d.]/, '') + (@long.negative? ? 'W' : 'E')
        else @long.round(8)
      end
    end

    # @return [AIXM::Component::Geometry::Point] convert to point
    def to_point
      AIXM.point(xy: self)
    end

    # @return [AIXM::D] distance as calculated by use of the Haversine formula
    def distance(other)
      if self == other
        AIXM.d(0, :m)
      else
        value = 2 * EARTH_RADIUS * Math.asin(
          Math.sqrt(
            Math.sin((other.lat.to_rad - lat.to_rad) / 2) ** 2 +
              Math.cos(lat.to_rad) * Math.cos(other.lat.to_rad) *
              Math.sin((other.long.to_rad - long.to_rad) / 2) ** 2
          )
        )
        AIXM.d(value.round, :m)
      end
    end

    # @see Object#==
    # @return [Boolean]
    def ==(other)
      self.class === other && lat == other.lat && long == other.long
    end
    alias_method :eql?, :==

    # @see Object#hash
    # @return [Integer]
    def hash
      to_s.hash
    end

    private

    def float_for(value)
      case value
        when Numeric then value.to_f
        when String then value.to_dd
        else fail(ArgumentError, "invalid value class `#{value.class}'")
      end
    rescue
      fail(ArgumentError, "invalid value `#{value}'")
    end

  end
end
