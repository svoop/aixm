require_relative '../../../spec_helper'

describe AIXM::Horizontal::Point do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM::Horizontal::Point.new(xy: 0) }.must_raise ArgumentError
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11.1, long: 22.2))
      subject.to_digest.must_equal '215d7cba'
    end
  end

  describe :to_xml do
    it "must build correct XML for N/E points" do
      subject = AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11.1, long: 22.2))
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>11.10000000N</geoLat>
          <geoLong>22.20000000E</geoLong>
        </Avx>
      END
    end

    it "must build correct XML for S/W points" do
      subject = AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: -11.1, long: -22.2))
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>11.10000000S</geoLat>
          <geoLong>22.20000000W</geoLong>
        </Avx>
      END
    end
  end
end
