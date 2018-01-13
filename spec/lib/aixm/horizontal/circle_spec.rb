require_relative '../../../spec_helper'

describe AIXM::Horizontal::Circle do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM::Horizontal::Circle.new(center_xy: 0, radius: 0) }.must_raise ArgumentError
    end
  end

  describe :north_xy do
    it "must calculate approximation of northmost point on the circumference" do
      subject = AIXM::Horizontal::Circle.new(
        center_xy: AIXM::XY.new(lat: 12.12345678, long: -23.12345678),
        radius: 15
      )
      subject.send(:north_xy).must_equal AIXM::XY.new(lat: 12.25835502, long: -23.12345678)
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM::Horizontal::Circle.new(
        center_xy: AIXM::XY.new(lat: 12.12345678, long: -23.12345678),
        radius: 15
      )
      subject.to_digest.must_equal '914C5F08'
    end
  end

  describe :to_xml do
    it "must build correct XML for circles not near the equator" do
      subject = AIXM::Horizontal::Circle.new(
        center_xy: AIXM::XY.new(lat: 11.1, long: 22.2),
        radius: 25
      )
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>CWA</codeType>
          <geoLat>111929.39N</geoLat>
          <geoLong>0221160.00E</geoLong>
          <geoLatArc>110560.00N</geoLatArc>
          <geoLongArc>0221160.00E</geoLongArc>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end

    it "must build correct XML for circles near the equator" do
      subject = AIXM::Horizontal::Circle.new(
        center_xy: AIXM::XY.new(lat: -0.0005, long: -22.2),
        radius: 50
      )
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>CWA</codeType>
          <geoLat>002656.98N</geoLat>
          <geoLong>0221160.00W</geoLong>
          <geoLatArc>000001.80S</geoLatArc>
          <geoLongArc>0221160.00W</geoLongArc>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end
  end
end
