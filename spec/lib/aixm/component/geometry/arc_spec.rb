require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::Arc do
  describe :initialize do
    it "won't accept invalid arguments" do
      xy = AIXM.xy(lat: 11.1, long: 22.2)
      -> { AIXM.arc(xy: 0, center_xy: xy, clockwise: true) }.must_raise ArgumentError
      -> { AIXM.arc(xy: xy, center_xy: 0, clockwise: true) }.must_raise ArgumentError
      -> { AIXM.arc(xy: xy, center_xy: xy, clockwise: 0) }.must_raise ArgumentError
    end
  end

  describe :clockwise? do
    it "must return true or false" do
      xy = AIXM.xy(lat: 11.1, long: 22.2)
      AIXM.arc(xy: xy, center_xy: xy, clockwise: true).must_be :clockwise?
      AIXM.arc(xy: xy, center_xy: xy, clockwise: false).wont_be :clockwise?
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM.arc(
        xy: AIXM.xy(lat: 11.1, long: 33.3),
        center_xy: AIXM.xy(lat: 22.2, long: 33.3),
        clockwise: true
      )
      subject.to_digest.must_equal 253842470
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
