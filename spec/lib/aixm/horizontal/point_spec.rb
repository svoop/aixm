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
      subject.to_digest.must_equal '215D7CBA'
    end
  end

  describe :to_xml do
    it "must build correct XML for N/E points" do
      subject = AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11.1, long: 22.2))
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>110560.00N</geoLat>
          <geoLong>0221160.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end

    it "must build correct XML for S/W points" do
      subject = AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: -11.1, long: -22.2))
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>110560.00S</geoLat>
          <geoLong>0221160.00W</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end
  end
end
