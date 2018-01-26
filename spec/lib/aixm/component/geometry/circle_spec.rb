require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::Circle do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM.circle(center_xy: 0, radius: 0) }.must_raise ArgumentError
    end
  end

  describe :north_xy do
    it "must calculate approximation of northmost point on the circumference" do
      subject = AIXM.circle(
        center_xy: AIXM.xy(lat: 12.12345678, long: -23.12345678),
        radius: 15
      )
      subject.send(:north_xy).must_equal AIXM.xy(lat: 12.25835502, long: -23.12345678)
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM.circle(
        center_xy: AIXM.xy(lat: 12.12345678, long: -23.12345678),
        radius: 15
      )
      subject.to_digest.must_equal 386055945
    end
  end

  describe :to_aixm do
    it "must build correct XML for circles not near the equator" do
      subject = AIXM.circle(
        center_xy: AIXM.xy(lat: 11.1, long: 22.2),
        radius: 25
      )
      subject.to_aixm.must_equal <<~END
        <Avx>
          <codeType>CWA</codeType>
          <geoLat>111929.39N</geoLat>
          <geoLong>0221200.00E</geoLong>
          <codeDatum>WGE</codeDatum>
          <geoLatArc>110600.00N</geoLatArc>
          <geoLongArc>0221200.00E</geoLongArc>
        </Avx>
      END
    end

    it "must build correct XML for circles near the equator" do
      subject = AIXM.circle(
        center_xy: AIXM.xy(lat: -0.0005, long: -22.2),
        radius: 50
      )
      subject.to_aixm.must_equal <<~END
        <Avx>
          <codeType>CWA</codeType>
          <geoLat>002656.98N</geoLat>
          <geoLong>0221200.00W</geoLong>
          <codeDatum>WGE</codeDatum>
          <geoLatArc>000001.80S</geoLatArc>
          <geoLongArc>0221200.00W</geoLongArc>
        </Avx>
      END
    end
  end
end
