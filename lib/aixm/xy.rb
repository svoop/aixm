using AIXM::Refinements

module AIXM

  # Geographical coordinates
  #
  # ===Warning!
  # Coordinate tuples can be noted in mathematical order (XY = longitude first,
  # latitude second) or in (more common) geographical order (YX = latitude
  # first, longitude second). However you sort the attributes, make sure not
  # to flip them by accident.
  #
  # See https://en.wikipedia.org/wiki/Geographic_coordinate_system
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
  # @see https://gitlab.com/openflightmaps/ofmx/wikis/Coordinates
  class XY
    include AIXM::Concerns::HashEquality

    EARTH_RADIUS = 6_371_008.8   # meters

    # See the {overview}[AIXM::XY] for examples.
    def initialize(lat:, long:)
      self.lat, self.long = lat, long
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} #{to_s}>)
    end

    # @return [String] human readable representation
    def to_s
      [lat(:ofmx), long(:ofmx)].join(' '.freeze)
    end

    # Latitude
    #
    # @!attribute lat
    # @overload lat
    #   @param schema [Symbol, nil] either +:aixm+ or +:ofmx+ or +nil+
    #   @return [String, Float]
    # @overload lat=(value)
    #   @param value [String, Numeric]
    def lat(schema=nil)
      case schema
        when :ofmx then ("%011.8f" % @lat.abs.round(8)) + (@lat.negative? ? 'S' : 'N')
        when :aixm then @lat.to_dms(2).gsub(/[^\d.]/, '') + (@lat.negative? ? 'S' : 'N')
        else @lat.round(8)
      end
    end

    def lat=(value)
      @lat = float_for value
      fail(ArgumentError, "invalid lat") unless (-90..90).include? @lat
    end

    # Longitude
    #
    # @!attribute long
    # @overload long
    #   @param schema [Symbol, nil] either +:aixm+ or +:ofmx+ or +nil+
    #   @return [String, Float]
    # @overload long=(value)
    #   @param value [String, Numeric]
    def long(schema=nil)
      case schema
        when :ofmx then ("%012.8f" % @long.abs.round(8)) + (@long.negative? ? 'W' : 'E')
        when :aixm then @long.to_dms(3).gsub(/[^\d.]/, '') + (@long.negative? ? 'W' : 'E')
        else @long.round(8)
      end
    end

    def long=(value)
      @long = float_for value
      fail(ArgumentError, "invalid long") unless (-180..180).include? @long
    end

    # Whether both longitude and latitude have zero DMS seconds (which may
    # indicate rounded or estimated coordinates).
    #
    # @return [Boolean]
    def seconds?
      !(long.to_dms[-6,5].to_f.zero? && lat.to_dms[-6,5].to_f.zero?)
    end

    # Convert to point
    #
    # @return [AIXM::Component::Geometry::Point]
    def to_point
      AIXM.point(xy: self)
    end

    # Distance to another point as calculated by the Haversine formula
    #
    # @return [AIXM::D]
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

    # Bearing to another point
    #
    # @return [AIXM::A]
    def bearing(other)
      fail "cannot calculate bearing to identical point" if self == other
      delta_long = other.long.to_rad - long.to_rad
      AIXM.a(
        Math.atan2(
          Math.cos(other.lat.to_rad) * Math.sin(delta_long),
          Math.cos(lat.to_rad) * Math.sin(other.lat.to_rad) -
            Math.sin(lat.to_rad) * Math.cos(other.lat.to_rad) *
            Math.cos(delta_long)
        ).to_deg
      )
    end

    # Calculate a new point by adding the distance in the given bearing
    #
    # @return [AIXM::XY]
    def add_distance(distance, bearing)
      angular_dist = distance.to_m.dim / EARTH_RADIUS
      dest_lat = Math.asin(
        Math.sin(lat.to_rad) * Math.cos(angular_dist) +
        Math.cos(lat.to_rad) * Math.sin(angular_dist) * Math.cos(bearing.to_f.to_rad)
      )
      dest_long = long.to_rad + Math.atan2(
        Math.sin(bearing.to_f.to_rad) * Math.sin(angular_dist) * Math.cos(lat.to_rad),
        Math.cos(angular_dist) - Math.sin(lat.to_rad) * Math.sin(dest_lat)
      )
      AIXM.xy(lat: dest_lat.to_deg, long: dest_long.to_deg)
    end

    # @see Object#==
    def ==(other)
      self.class === other && lat == other.lat && long == other.long
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
