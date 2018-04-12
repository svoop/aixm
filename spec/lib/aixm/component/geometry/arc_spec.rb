require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::Arc do
  subject do
    AIXM.arc(
      xy: AIXM.xy(lat: 11.1, long: 33.3),
      center_xy: AIXM.xy(lat: 22.2, long: 33.3),
      clockwise: true
    )
  end

  describe :center_xy= do
    it "fails on invalid values" do
      [nil, 123].wont_be_written_to subject, :xy
    end

    it "accepts valid values" do
      [AIXM::Factory.xy].must_be_written_to subject, :xy
    end
  end

  describe :clockwise= do
    it "fails on invalid values" do
      [nil, 0].wont_be_written_to subject, :clockwise
    end
  end

  describe :clockwise? do
    it "must return true or false" do
      xy = AIXM.xy(lat: 11.1, long: 22.2)
      AIXM.arc(xy: xy, center_xy: xy, clockwise: true).must_be :clockwise?
      AIXM.arc(xy: xy, center_xy: xy, clockwise: false).wont_be :clockwise?
    end
  end

  describe :to_xml do
    it "builds correct AIXM for clockwise arcs" do
      subject = AIXM.arc(
        xy: AIXM.xy(lat: 11.1, long: 33.3),
        center_xy: AIXM.xy(lat: 22.2, long: 33.3),
        clockwise: true
      )
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>CWA</codeType>
          <geoLat>110600.00N</geoLat>
          <geoLong>0331800.00E</geoLong>
          <codeDatum>WGE</codeDatum>
          <geoLatArc>221200.00N</geoLatArc>
          <geoLongArc>0331800.00E</geoLongArc>
        </Avx>
      END
    end

    it "builds correct AIXM for counter-clockwise arcs" do
      subject = AIXM.arc(
        xy: AIXM.xy(lat: 11.1, long: 33.3),
        center_xy: AIXM.xy(lat: 22.2, long: 33.3),
        clockwise: false
      )
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>CCA</codeType>
          <geoLat>110600.00N</geoLat>
          <geoLong>0331800.00E</geoLong>
          <codeDatum>WGE</codeDatum>
          <geoLatArc>221200.00N</geoLatArc>
          <geoLongArc>0331800.00E</geoLongArc>
        </Avx>
      END
    end
  end
end
