require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::Circle do
  subject do
    AIXM.circle(
      center_xy: AIXM.xy(lat: 12.12345678, long: -23.12345678),
      radius: AIXM.d(15, :km)
    )
  end

  describe :center_xy= do
    it "fails on invalid values" do
      [nil, 123].wont_be_written_to subject, :center_xy
    end

    it "accepts valid values" do
      [AIXM::Factory.xy].must_be_written_to subject, :center_xy
    end
  end

  describe :radius= do
    it "fails on invalid values" do
      [nil, 0, 2, AIXM.d(0, :m)].wont_be_written_to subject, :radius
    end
  end

  describe :north_xy do
    it "must calculate approximation of northmost point on the circumference" do
      subject.send(:north_xy).must_equal AIXM.xy(lat: 12.25835483455868, long: -23.12345678)
    end
  end

  describe :to_xml do
    it "builds correct AIXM for circles not near the equator" do
      subject = AIXM.circle(
        center_xy: AIXM.xy(lat: 11.1, long: 22.2),
        radius: AIXM.d(25, :km)
      )
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
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

    it "builds correct AIXM for circles near the equator" do
      subject = AIXM.circle(
        center_xy: AIXM.xy(lat: -0.0005, long: -22.2),
        radius: AIXM.d(50, :km)
      )
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
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
