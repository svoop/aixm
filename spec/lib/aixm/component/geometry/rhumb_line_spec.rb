require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::RhumbLine do
  subject do
    AIXM.rhumb_line(xy: AIXM.xy(lat: 11.1, long: 22.2))
  end

  describe :xy= do
    macro :xy
  end

  describe :to_xml do
    it "builds correct AIXM for N/E points" do
      subject = AIXM.rhumb_line(xy: AIXM.xy(lat: 11.1, long: 22.2))
      _(subject.to_xml).must_equal <<~END
        <Avx>
          <codeType>RHL</codeType>
          <geoLat>110600.00N</geoLat>
          <geoLong>0221200.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end

    it "builds correct AIXM for S/W points" do
      subject = AIXM.rhumb_line(xy: AIXM.xy(lat: -11.1, long: -22.2))
      _(subject.to_xml).must_equal <<~END
        <Avx>
          <codeType>RHL</codeType>
          <geoLat>110600.00S</geoLat>
          <geoLong>0221200.00W</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end
  end
end
