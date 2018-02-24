require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::Point do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM.point(xy: 0) }.must_raise ArgumentError
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM.point(xy: AIXM.xy(lat: 11.1, long: 22.2))
      subject.to_digest.must_equal 167706171
    end
  end

  describe :to_xml do
    it "must build correct AIXM for N/E points" do
      AIXM.aixm!
      subject = AIXM.point(xy: AIXM.xy(lat: 11.1, long: 22.2))
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>110600.00N</geoLat>
          <geoLong>0221200.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end

    it "must build correct AIXM for S/W points" do
      AIXM.aixm!
      subject = AIXM.point(xy: AIXM.xy(lat: -11.1, long: -22.2))
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
