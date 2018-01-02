module AIXM

  ##
  # Geographical coordinates
  #
  # The following notations for longitude and latitude are recognized:
  # * DD - see https://en.wikipedia.org/wiki/Decimal_degrees
  #        examples: 12.12345678 (north or east), -12.12345678 (south or west)
  # * DMS - see https://en.wikipedia.org/wiki/Degree_(angle)
  #         examples: 11°22'33.44"N, 111 22 33.44 W
  class XY

    def initialize(lat:, long:)
      @lat, @long = float_for(lat), float_for(long)
      fail(ArgumentError, "illegal latitude") unless (-90..90).include? @lat
      fail(ArgumentError, "illegal longitude") unless (-180..180).include? @long
    end

    def lat
      @lat.round(8)
    end

    def long
      @long.round(8)
    end

    def ==(other)
      other.is_a?(XY) && lat == other.lat && long == other.long
    end

    private

    def float_for(value)
      return value.to_f if value.is_a? Numeric
      if value.to_s =~ /^\s*(\d+)[° ]+(\d+)[' ]+([\d.]+)[" ]*(?:(N|E)|(S|W))\s*$/
        ($1.to_f + ($2.to_f/60) + ($3.to_f/3600)) * ($4 ? 1 : -1)
      else
        fail(ArgumentError, "illegal value `#{value}'")
      end
    end

  end
end
