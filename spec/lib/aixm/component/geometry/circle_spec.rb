require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::Circle do
  subject do
    AIXM.circle(
      center_xy: AIXM.xy(lat: 12.12345678, long: -23.12345678),
      radius: 15
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

  describe :radius= do
    it "fails on invalid values" do
      -> { subject.radius = :foo }.must_raise ArgumentError
      -> { subject.radius = 0 }.must_raise ArgumentError
      -> { subject.radius = -5 }.must_raise ArgumentError
    end

    it "converts Numeric to Float" do
      subject.tap { |s| s.radius = 5 }.radius.must_equal 5.0
    end
  end

  describe :north_xy do
    it "must calculate approximation of northmost point on the circumference" do
      subject.send(:north_xy).must_equal AIXM.xy(lat: 12.25835483455868, long: -23.12345678)
    end
  end

  describe :to_xml do
    it "must build correct AIXM for circles not near the equator" do
      subject = AIXM.circle(
        center_xy: AIXM.xy(lat: 11.1, long: 22.2),
        radius: 25
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

    it "must build correct AIXM for circles near the equator" do
      subject = AIXM.circle(
        center_xy: AIXM.xy(lat: -0.0005, long: -22.2),
        radius: 50
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
