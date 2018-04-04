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
      -> { subject.center_xy = 123 }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.center_xy = AIXM::Factory.xy }.center_xy.must_equal AIXM::Factory.xy
    end
  end

  describe :clockwise= do
    it "fails on invalid values" do
      -> { subject.clockwise = 0 }.must_raise ArgumentError
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
    it "must build correct AIXM for clockwise arcs" do
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

    it "must build correct AIXM for counter-clockwise arcs" do
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
