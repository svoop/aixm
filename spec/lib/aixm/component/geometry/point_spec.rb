require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::Point do
  subject do
    AIXM.point(xy: AIXM.xy(lat: 11.1, long: 22.2))
  end

  describe :xy= do
    macro :xy
  end

  describe :to_xml do
    it "builds correct AIXM for N/E points" do
      subject = AIXM.point(xy: AIXM.xy(lat: 11.1, long: 22.2))
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>110600.00N</geoLat>
          <geoLong>0221200.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end

    it "builds correct AIXM for S/W points" do
      subject = AIXM.point(xy: AIXM.xy(lat: -11.1, long: -22.2))
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>110600.00S</geoLat>
          <geoLong>0221200.00W</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end
  end
end
